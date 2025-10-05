#!/usr/bin/env bash
# shell_hooks.sh — унифицированное поведение deactivate

deactivate() {
  if [[ -n "${_OLD_VIRTUAL_PATH:-}" || -n "${VIRTUAL_ENV:-}" ]]; then
    # Если есть оригинальная deactivate
    if declare -F deactivate_original >/dev/null; then
      deactivate_original "$@"
    else
      # Для direnv
      echo "💡 Direnv управляет окружением — выполняю direnv reload..."
      direnv reload
    fi
  else
    echo "⚠️ Окружение не активно."
  fi
}
