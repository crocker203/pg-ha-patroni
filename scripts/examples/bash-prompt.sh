#!/usr/bin/env bash
# Это не самостоятельный скрипт, это пример блока который можно добавить в конец .bashrc
# Пример кастомной подсказки для Bash с отображением активного venv

# Подключаем direnv hook (если еще не подключен в .bashrc)
eval "$(direnv hook bash)"

# --- Кастомная подсказка с отображением venv ---
function set_bash_prompt() {
    local EXIT="$?"
    local VENV=""

    if [ -n "$VIRTUAL_ENV" ]; then
        VENV="\[\033[01;33m\]($(basename $VIRTUAL_ENV))\[\033[00m\] "
    fi

    local GREEN="\[\033[01;32m\]"
    local BLUE="\[\033[01;34m\]"
    local RESET="\[\033[00m\]"

    PS1="${VENV}${GREEN}\u@\h${RESET}:${BLUE}\w${RESET}\$ "
}

# Если PROMPT_COMMAND уже есть, добавим вызов функции
if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND=set_bash_prompt
else
    PROMPT_COMMAND="$PROMPT_COMMAND; set_bash_prompt"
fi
