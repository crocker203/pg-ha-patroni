#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
INIT_DIR="$ROOT_DIR/scripts/init"
IMAGES_DIR="$ROOT_DIR/vagrant_images"

echo "🚀 Запуск полной инициализации проекта pg-ha-patroni..."

# 1️⃣ Исправляем права
bash "$ROOT_DIR/scripts/fix_permissions.sh"

# 2️⃣ Проверяем/создаём директорию для образов Vagrant
if [ ! -d "$IMAGES_DIR" ]; then
  mkdir -p "$IMAGES_DIR"
  echo "📁 Создана папка $IMAGES_DIR для образов VM"
else
  echo "📁 Папка $IMAGES_DIR уже существует"
fi

# 3️⃣ Настраиваем .envrc
bash "$INIT_DIR/setup_envrc.sh"

# 4️⃣ Создаём виртуальное окружение Ansible (если нет)
bash "$INIT_DIR/setup_python_venv.sh"

echo "✅ Инициализация проекта успешно завершена"
