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

Пример установки на Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y git vagrant python3 python3-pip direnv libvirt-clients libvirt-daemon-system qemu nano
```

⚠️ В дальнейшем можно использовать скрипт `scripts/init/setup_system.sh` для автоматизации установки под разные дистрибутивы.

---

## 🚀 Быстрый старт

```bash
git clone git@github.com:you/pg-ha-patroni.git
cd pg-ha-patroni
scripts/fix_executable_rights.sh           # один раз, чтобы все скрипты стали исполняемыми и зафиксировались в Git (ОПЦИОНАЛЬНО, по умолчанию файлы УЖЕ ИСПОЛНЯЕМЫЕ при клонировании)
make init                                  # создание venv, установка ansible, генерация .envrc
direnv allow                               # разрешение direnv выполнять .envrc (выполнить в корневой директории проекта)
make setup [inventory_node_name]           # (опционально) установка системных зависимостей
make up [inventory_node_name]              # поднять кластер
make ansible [inventory_node_name]         # проверить доступность нод
```

⚠️ После клона проекта .envrc ещё не существует. 
Сначала выполните make init, чтобы его создать.
После этого появится ошибка вида "`direnv: error /path/to/pg-ha-patroni/.envrc is blocked. Run 'direnv allow' to approve its content`
связано с тем что direnv блокирует `.envrc` по умолчанию - ЭТО НОРМАЛЬНО
Затем один раз выполните direnv allow. После этого direnv будет автоматически активировать виртуальное окружение и устанавливать переменные окружения при входе в папку проекта.

---

### ⚡ Исправление прав для скриптов

Перед первым запуском любого скрипта рекомендуется проверить права всех `.sh` в `scripts/`:

```bash
scripts/fix_executable_rights.sh
```

✅ Скрипт сделает все `.sh` исполняемыми и зафиксирует это в Git.  
Это особенно полезно для новых разработчиков и при работе на разных машинах.

---

## ⚙️ Makefile команды

- `make setup` → установка системных пакетов  
- `make init` → подготовка venv, ansible и `.envrc`  
- `make up [inventory_node_name] / halt [inventory_node_name] / destroy [inventory_node_name]` → управление кластером Vagrant  
- `make ssh [inventory_node_name]` → доступ к нодам  
- `make ansible [inventory_node_name]` → проверка доступности всех нод  

Подробное описание всех команд и workflow — [docs/WORKFLOW.md](docs/WORKFLOW.md)

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

Детали про автоматическую активацию venv и экспорт переменных окружения — [docs/DIRENV.md](docs/DIRENV.md)

---

## 🎨 Кастомная подсказка с venv

Чтобы видеть активный venv в PS1:

- Добавьте содержимое `scripts/examples/bash-prompt.sh` в конец `~/.bashrc` или `~/.zshrc`  
- Перезапустите терминал или выполните `source ~/.bashrc`  

---

## 📌 Примечания

- Все внутренние скрипты и роли используют переменную `$PG_HA_PATRONI_HOME` для определения корня проекта  
- Полная документация, диаграммы workflow и инструкции по ролям Ansible находятся в папке `docs`
