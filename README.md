# pg-ha-patroni

Инфраструктура для кластера **PostgreSQL** с **Patroni** и **Consul**, развёртываемая через **Ansible** и **Vagrant/libvirt**.

---

## 🚀 Быстрый старт

git clone git@github.com:you/pg-ha-patroni.git
cd pg-ha-patroni
make setup      # установка системных зависимостей
make init       # создание venv, установка ansible, генерация .envrc
direnv allow    # разрешение direnv выполнять .envrc
make up         # поднять кластер
make ansible    # проверить доступность нод

---

## ⚙️ Makefile команды

- make setup → установка системных пакетов
- make init → подготовка venv, ansible и .envrc
- make up / halt / destroy → управление кластером Vagrant
- make ssh / consul / db1 / db2 → доступ к нодам
- make ansible → проверка доступности всех нод

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
