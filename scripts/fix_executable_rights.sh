#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🔧 Исправляем права на все .sh скрипты в $ROOT_DIR/scripts/"

find "$ROOT_DIR/scripts" -type f -name "*.sh" | while read -r file; do
    CHANGED=false

    # Проверяем локальные права
    if [ ! -x "$file" ]; then
        chmod +x "$file"
        CHANGED=true
    fi

    # Проверяем, отслеживается ли Git
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        # Проверяем, есть ли флаг +x в Git
        if ! git ls-files --stage "$file" | grep -q '^100755'; then
            git update-index --chmod=+x "$file"
            CHANGED=true
        fi
    else
        git add "$file"
        git update-index --chmod=+x "$file"
        CHANGED=true
    fi

    # Выводим только если что-то изменилось
    if [ "$CHANGED" = true ]; then
        echo "✅ Исправлено и зафиксировано в Git: $file"
    fi
done

echo "🎉 Все скрипты в scripts/ теперь исполняемые и права зафиксированы в Git."
