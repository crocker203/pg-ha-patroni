# pg-ha-patroni

Инфраструктура для кластера **PostgreSQL** с **Patroni** и **Consul**, развёртываемая через **Ansible** и **Vagrant/libvirt**.

---

### Системные зависимости

Для работы проекта должны быть установлены:

- Git
- Vagrant и провайдер libvirt (или VirtualBox)
- Direnv
- Python 3 и pip
- libvirt / qemu / virt-manager (если используете vagrant-libvirt)
- nano или vim (опционально)

Вы можете установить их вручную:

```bash
# Ubuntu/Debian пример
sudo apt update
sudo apt install -y git vagrant python3 python3-pip direnv libvirt-clients libvirt-daemon-system qemu nano
```

⚠️ В дальнейшем можно использовать скрипт `scripts/init/setup_system.sh` для автоматизации установки под разные дистрибутивы.

---

## 🚀 Быстрый старт

```bash
git clone git@github.com:you/pg-ha-patroni.git
cd pg-ha-patroni
make setup                            # (ОПЦИОНАЛЬНО) установка системных зависимостей
direnv allow                          # разрешение direnv выполнять .envrc
make init                             # создание venv, установка ansible, генерация .envrc
make up [inventory_node_name]         # поднять кластер
make ansible [inventory_node_name]    # проверить доступность нод
```

### ⚡ Исправление прав для скриптов

Перед первым запуском любого скрипта (особенно после клона проекта) рекомендуется проверить и зафиксировать права для всех `.sh` в `scripts/`:

```bash
scripts/fix_executable_rights.sh
```

✅ Скрипт сделает все `.sh` исполняемыми и зафиксирует это в Git.  
Это особенно полезно для новых разработчиков и при работе на разных машинах.

---

## ⚙️ Makefile команды

- `make setup` → установка системных пакетов  
- `make init` → подготовка venv, ansible и .envrc  
- `make up [inventory_node_name]` / `halt [inventory_node_name]` / `destroy [inventory_node_name]` → управление кластером Vagrant  
- `make ssh inventory_node_name` → доступ к нодам  
- `make ansible [inventory_node_name]` → проверка доступности всех нод  

Подробное описание всех команд и workflow — `docs/WORKFLOW.md`

---

## 🛠️ Direnv и venv

Добавьте один раз в `~/.bashrc` или `~/.zshrc`:

```bash
eval "$(direnv hook bash)"
```

После `make init` активируйте `.envrc`:

```bash
direnv allow
```

Детали про автоматическую активацию venv и экспорт переменных окружения — `docs/DIRENV.md`

⚠️ После клона проекта `.envrc` будет блокирован по умолчанию, поэтому нужно один раз выполнить `direnv allow`.  
Иначе будет ошибка:

```
direnv: error /path/to/pg-ha-patroni/.envrc is blocked. Run 'direnv allow' to approve its content
```

---

## 🎨 Кастомная подсказка с venv

Чтобы видеть активный venv в PS1:

- Добавьте содержимое `scripts/examples/bash-prompt.sh` в конец `~/.bashrc` или `~/.zshrc`  
- Перезапустите терминал или выполните:

```bash
source ~/.bashrc
```

Подробнее — `scripts/examples/bash-prompt.sh`

---

## 📌 Примечания

- Все пути и переменные окружения зависят от `$PG_HA_PATRONI_HOME`  
- Полная документация, диаграммы workflow и инструкции по ролям Ansible находятся в папке `docs`
