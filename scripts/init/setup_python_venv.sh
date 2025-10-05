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

# Устанавливаем переменную PG_HA_PATRONI_HOME, если она не задана
if [ -z "${PG_HA_PATRONI_HOME:-}" ]; then
    export PG_HA_PATRONI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
fi
EOF
)

if ! grep -q 'PG_HA_PATRONI_HOME' "$ACTIVATE_FILE"; then
    echo "$BLOCK" >> "$ACTIVATE_FILE"
    echo "Добавлен блок PG_HA_PATRONI_HOME в $ACTIVATE_FILE"
fi

echo "✅ Виртуальное окружение создано и зависимости установлены"
