#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VENV_DIR="$ROOT_DIR/ansible-venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Создаем виртуальное окружение ansible-venv..."
    python3 -m venv "$VENV_DIR"
fi

# Устанавливаем зависимости ansible
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$ROOT_DIR/requirements-ansible.txt"

# Добавляем установку PG_HA_PATRONI_HOME в venv/bin/activate, если ещё не добавлена
ACTIVATE_FILE="$ROOT_DIR/ansible-venv/bin/activate"
BLOCK=$(cat <<'EOF'

# Динамическое определение корня проекта и пути до конфига ansible при каждом заходе в папку
export PG_HA_PATRONI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
export ANSIBLE_CONFIG="$PG_HA_PATRONI_HOME/ansible.cfg"

# Подключаем shell-hooks для унификации deactivate
if [ -f "$PG_HA_PATRONI_HOME/scripts/shell_hooks.sh" ]; then
    # Сохраняем оригинальную deactivate, если есть
    if declare -F deactivate >/dev/null; then
        deactivate_original() { command deactivate "$@"; }
    fi
    source "$PG_HA_PATRONI_HOME/scripts/shell_hooks.sh"
fi

EOF
)

if ! grep -q 'PG_HA_PATRONI_HOME' "$ACTIVATE_FILE"; then
    echo "$BLOCK" >> "$ACTIVATE_FILE"
    echo "Добавлен блок инициализации переменных [PG_HA_PATRONI_HOME, ANSIBLE_CONFIG] в $ACTIVATE_FILE"
fi
echo
echo "⚠️  Для работы с проектом активируйте виртуальное окружение вручную: source ansible-venv/bin/activate"
echo "⚠️  Переменные PG_HA_PATRONI_HOME, ANSIBLE_CONFIG будут инициализированы автоматически при активации виртуального окружения"
echo "⚠️  После работы с проектом деактивируйте виртуальное окружение вручную: deactivate"
echo "⚠️  Без инициализации переменных PG_HA_PATRONI_HOME, ANSIBLE_CONFIG проект работать не будет"
echo
echo "✅ Виртуальное окружение создано и зависимости установлены"
