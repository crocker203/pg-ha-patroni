#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ENVRC_FILE="$ROOT_DIR/.envrc"

echo "⚙️ Настройка автоматической активации окружения через direnv..."

# Проверяем, что ansible-venv существует
if [ ! -d "$ROOT_DIR/ansible-venv" ]; then
    echo "❌ Виртуальное окружение ansible-venv не найдено. Сначала выполните make init."
    exit 1
fi

cat > "$ENVRC_FILE" <<'EOF'
# >>> direnv configuration for pg-ha-patroni >>>

# Устанавливаем корень проекта
export PG_HA_PATRONI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Активируем Python virtualenv через абсолютный путь
layout python "$PG_HA_PATRONI_HOME/ansible-venv"

# <<< end direnv configuration <<<
EOF

echo "✅ Файл .envrc создан по пути: $ENVRC_FILE"
echo ""
echo "Теперь выполните команду:"
echo "  direnv allow"
echo ""
echo "После этого окружение будет автоматически активироваться при заходе в проект."

#cat > "$ENVRC_FILE" <<'EOF'
# Активируем виртуальное окружение ansible-venv
#if [ -f "$PG_HA_PATRONI_HOME/ansible-venv/bin/activate" ]; then
#    source "$PG_HA_PATRONI_HOME/ansible-venv/bin/activate"
#fi
#EOF

#echo "✅ .envrc создан для direnv"
