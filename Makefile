# Makefile для pg-ha-patroni

# Переменные
VAGRANT_BIN := vagrant
ANSIBLE_PLAYBOOK := ansible-playbook
PROJECT_DIR := $(shell pwd)

# -----------------------------
# Системная подготовка
# -----------------------------
.PHONY: setup
setup:
	@echo "🔧 Установка системных пакетов..."
	@./scripts/init/setup_system.sh || echo "⚠️ setup_system.sh не найден, пропускаем"

# -----------------------------
# Инициализация проекта
# -----------------------------
.PHONY: init
init:
	@echo "🚀 Инициализация проекта..."

	# Проверка зависимостей
	@command -v direnv >/dev/null 2>&1 || (echo "⚠️  direnv не установлен. Поставьте через 'sudo apt install direnv' или аналог." && exit 1)
	@command -v vagrant >/dev/null 2>&1 || (echo "⚠️  Vagrant не установлен. Скачайте с https://www.vagrantup.com/downloads/" && exit 1)
	@command -v git >/dev/null 2>&1 || (echo "⚠️  Git не установлен. Поставьте git и повторите." && exit 1)

	# Запуск скрипта инициализации
	@bash scripts/init/init.sh

# -----------------------------
# Управление Vagrant с аргументами
# -----------------------------
.PHONY: up halt destroy db1 db2 consul

up:
	@echo "📦 Поднимаем кластер..."
	@$(VAGRANT_BIN) up $(filter-out $@,$(MAKECMDGOALS))

halt:
	@echo "⏸️ Останавливаем кластер..."
	@$(VAGRANT_BIN) halt $(filter-out $@,$(MAKECMDGOALS))

destroy:
	@echo "💣 Удаляем кластер..."
	@$(VAGRANT_BIN) destroy -f $(filter-out $@,$(MAKECMDGOALS))

# Пустые цели для VM, чтобы Make не ругался на неизвестные цели
db1 db2 consul:
	@:

# -----------------------------
# SSH доступ к нодам с аргументами
# -----------------------------
.PHONY: ssh

ssh:
	@echo "🔑 Подключаемся к VM через Vagrant SSH..."
	@$(VAGRANT_BIN) ssh $(filter-out $@,$(MAKECMDGOALS))

# -----------------------------
# Ansible с выбором группы/хоста
# -----------------------------
.PHONY: ansible

ansible:
	@echo "🎯 Проверка доступности нод через Ansible..."
	@$(ANSIBLE_PLAYBOOK) -i ansible/learn-inventory/inventory.ini --list-hosts $(filter-out $@,$(MAKECMDGOALS))

# -----------------------------
# Пустые цели для поддержки аргументов ansible
# -----------------------------
consul db:
	@:
