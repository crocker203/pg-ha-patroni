#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

echo "🚀 Инициализация проекта..."

# 1️⃣ Устанавливаем git pre-commit hook
"$ROOT_DIR/scripts/init/setup_git_hooks.sh"

# 2️⃣ Создаём и настраиваем Python virtualenv для ansible
"$ROOT_DIR/scripts/init/setup_python_venv.sh"

# 3️⃣ Создаём каталог для образов Vagrant (если не существует)
mkdir -p "$ROOT_DIR/vagrant_images"

# 4️⃣ Настройка direnv для автоматической активации виртуального окружения при заходе в корневую папку проекта
"$ROOT_DIR/scripts/init/setup_envrc.sh"

echo "✅ Инициализация завершена успешно!"
