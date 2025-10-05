# Direnv и автоматическая активация venv

Проект использует **direnv** для автоматической активации виртуального окружения и установки переменных окружения.

---

## Подключение direnv к оболочке

Добавьте **один раз** в `~/.bashrc` или `~/.zshrc`:

```bash
eval "$(direnv hook bash)"
```

> ⚠️ Без этой строки direnv не сможет автоматически исполнять `.envrc`.

---

## Использование

1. После `make init` в корне проекта будет создан файл `.envrc`:

```bash
export PG_HA_PATRONI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ANSIBLE_CONFIG=$PG_HA_PATRONI_HOME/ansible.cfg
source $PG_HA_PATRONI_HOME/ansible-venv/bin/activate
```

2. Разрешите direnv исполнять `.envrc`:

```bash
direnv allow
```

---

## Что происходит при заходе в папку проекта

- Автоматически активируется виртуальное окружение `ansible-venv`
- Устанавливаются переменные окружения:
  - `$PG_HA_PATRONI_HOME` — путь к корню проекта
  - `$ANSIBLE_CONFIG` — путь к конфигурации Ansible

> 💡 После клона проекта `.envrc` будет **заблокирован**, и direnv выдаст сообщение:  
> `direnv: error /path/to/pg-ha-patroni/.envrc is blocked. Run 'direnv allow' to approve its content.`

---

### Полезные советы

- Для проверки работы venv можно выполнить:

```bash
echo $PG_HA_PATRONI_HOME
which ansible
```

- Если нужно временно деактивировать direnv:

```bash
direnv deny
```

- Любые изменения в `.envrc` потребуют повторного `direnv allow`.
