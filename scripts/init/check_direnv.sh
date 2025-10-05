#!/usr/bin/env bash
set -euo pipefail

if ! command -v direnv >/dev/null 2>&1; then
    echo "Внимание: direnv не установлен. Пожалуйста, установите его для автоматической активации venv"
else
    echo "direnv установлен"
fi
