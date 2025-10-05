# Direnv и автоматическая активация venv

Проект использует direnv для автоматической активации виртуального окружения и установки переменных окружения.

## Подключение direnv к оболочке

Добавьте один раз в ~/.bashrc или ~/.zshrc:

eval "$(direnv hook bash)"

## Использование

1. После make init в корне проекта будет создан файл .envrc:

export PG_HA_PATRONI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ANSIBLE_CONFIG=$PG_HA_PATRONI_HOME/ansible.cfg
source $PG_HA_PATRONI_HOME/ansible-venv/bin/activate

2. Разрешите direnv исполнять .envrc:

direnv allow

Теперь при заходе в папку проекта:

- Активируется виртуальное окружение ansible-venv
- Устанавливаются переменные окружения $PG_HA_PATRONI_HOME и $ANSIBLE_CONFIG
