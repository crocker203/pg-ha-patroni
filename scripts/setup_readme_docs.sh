#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS_DIR="$ROOT/docs"

mkdir -p "$DOCS_DIR"

# Мини-README.md
cat > "$ROOT/README.md" <<'EOF'
# pg-ha-patroni

Инфраструктура для кластера **PostgreSQL** с **Patroni** и **Consul**, развёртываемая через **Ansible** и **Vagrant/libvirt**.

---

## 🚀 Быстрый старт

git clone git@github.com:you/pg-ha-patroni.git
cd pg-ha-patroni
make setup                         # установка системных зависимостей
make init                          # создание venv, установка ansible, генерация .envrc
direnv allow                       # разрешение direnv выполнять .envrc
make up [node_inventory]           # поднять кластер
make ansible [node_inventory]      # проверить доступность нод

---

## ⚙️ Makefile команды

- make setup → установка системных пакетов
- make init → подготовка venv, ansible и .envrc
- make up [node_inventory] / halt [node_inventory] / destroy [node_inventory] → управление кластером Vagrant
- make ssh node_inventory → доступ к нодам
- make ansible [node_inventory] → проверка доступности всех нод

Подробное описание всех команд и workflow — docs/WORKFLOW.md

---

## 🛠️ Direnv и venv

Добавьте один раз в ~/.bashrc или ~/.zshrc:

eval "$(direnv hook bash)"

После make init активируйте .envrc:
direnv allow

Детали про автоматическую активацию venv и экспорт переменных окружения — docs/DIRENV.md

---

## 🎨 Кастомная подсказка с venv

Чтобы видеть активный venv в PS1:

- Добавьте содержимое scripts/examples/bash-prompt.sh в КОНЕЦ~/.bashrc или ~/.zshrc
- Перезапустите терминал или выполните source ~/.bashrc

Подробнее — scripts/examples/bash-prompt.sh

---

## 📌 Примечания

- Все пути и переменные окружения зависят от $PG_HA_PATRONI_HOME
- Полная документация, диаграммы workflow и инструкции по ролям Ansible находятся в папке docs
EOF

# WORKFLOW.md
cat > "$DOCS_DIR/WORKFLOW.md" <<'EOF'
# Workflow проекта pg-ha-patroni

## Полный цикл работы проекта


┌──────────────┐
│ Git clone    │
│ pg-ha-patroni│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ make setup   │
│ (системные)  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ make init    │
│ (venv, ansible, .envrc) │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ direnv allow │
│ (активация venv и переменных) │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ make up      │
│ (поднять кластер) │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ make ansible │
│ (проверка доступности) │
└──────┬───────┘
       │
       ▼
┌───────────────┐
│ Кластер       │
│ работает      │
└──────┬────────┘
       │
 ┌─────┴────────┐
 │              │
 ▼              ▼
make halt     make destroy
│              │
│ После halt можно выключить компьютер
│ и потом продолжить работу с кластером
│ используя make up / vagrant up
└──────────────┘

### Пояснения

- make halt — остановка VM, сохраняется состояние кластера на диски
- make destroy — удаление всего кластера и информации о нем с дисков
- Диаграмма показывает полный цикл: установка → инициализация → поднятие → проверка → управление кластером
EOF

# DIRENV.md
cat > "$DOCS_DIR/DIRENV.md" <<'EOF'
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
EOF


echo "✅ Мини-README и docs/ успешно созданы!"
