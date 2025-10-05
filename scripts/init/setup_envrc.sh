#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ENVRC_FILE="$ROOT_DIR/.envrc"

cat > "$ENVRC_FILE" <<'EOF'
# Динамическое определение корня проекта при каждом заходе в папку
export PG_HA_PATRONI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ANSIBLE_CONFIG="$PG_HA_PATRONI_HOME/ansible.cfg"

# Активируем виртуальное окружение ansible-venv
if [ -f "$PG_HA_PATRONI_HOME/ansible-venv/bin/activate" ]; then
    source "$PG_HA_PATRONI_HOME/ansible-venv/bin/activate"
fi
EOF

echo "✅ .envrc создан для direnv с динамическим PG_HA_PATRONI_HOME"
