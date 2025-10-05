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

echo "✅ Виртуальное окружение создано и зависимости установлены"
