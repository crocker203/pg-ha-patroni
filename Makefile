# Makefile для pg-ha-patroni

VAGRANT_BIN := vagrant
ANSIBLE_PLAYBOOK := ansible-playbook
PG_HA_PATRONI_HOME := $(shell pwd)
SSH_KEY_PATH := $(PG_HA_PATRONI_HOME)/.ssh/id_ed25519

.PHONY: setup
setup:
	@echo "🔧 Установка системных пакетов..."
	@./scripts/init/setup_system.sh || echo "⚠️ setup_system.sh не найден, пропускаем"

.PHONY: init
init:
	@echo "🚀 Инициализация проекта..."
	@command -v direnv >/dev/null 2>&1 || (echo "⚠️ direnv не установлен" && exit 1)
	@command -v vagrant >/dev/null 2>&1 || (echo "⚠️ Vagrant не установлен" && exit 1)
	@command -v git >/dev/null 2>&1 || (echo "⚠️ Git не установлен" && exit 1)

	# Генерация SSH ключа, если отсутствует
	@if [ ! -f "$(SSH_KEY_PATH)" ]; then \
		echo "🔑 Генерируем SSH ключ для Vagrant/Ansible..."; \
		mkdir -p $(PG_HA_PATRONI_HOME)/.ssh; \
		ssh-keygen -t ed25519 -f $(SSH_KEY_PATH) -N "" -q; \
	fi

	# Устанавливаем переменную окружения для Ansible
	@echo "export ANSIBLE_PRIVATE_KEY_FILE=$(SSH_KEY_PATH)" > $(PG_HA_PATRONI_HOME)/.envrc
	@echo "export PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME)" >> $(PG_HA_PATRONI_HOME)/.envrc
	@echo "✅ SSH ключ и окружение готовы. Выполните 'direnv allow'"

	# Выполняем скрипт инициализации проекта
	@bash scripts/init/init.sh

.PHONY: up halt destroy db1 db2 consul

up:
	@echo "📦 Поднимаем кластер..."
	@if virsh list --all | grep -q "pg-ha-patroni_$(filter-out $@,$(MAKECMDGOALS))"; then \
		echo "⚠️  VM уже существует. Удаляем старый домен..."; \
		virsh undefine pg-ha-patroni_$(filter-out $@,$(MAKECMDGOALS)) --remove-all-storage || true; \
	fi
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) SSH_KEY_PATH=$(SSH_KEY_PATH) $(VAGRANT_BIN) up $(filter-out $@,$(MAKECMDGOALS))

halt:
	@echo "⏸️ Останавливаем кластер..."
	@$(VAGRANT_BIN) halt $(filter-out $@,$(MAKECMDGOALS))

destroy:
	@echo "💣 Удаляем кластер..."
	@$(VAGRANT_BIN) destroy -f $(filter-out $@,$(MAKECMDGOALS))

db1 db2 consul:
	@:

.PHONY: ssh
ssh:
	@echo "🔑 Подключаемся к VM через SSH..."
	@$(VAGRANT_BIN) ssh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: ansible
ansible:
	@echo "🎯 Проверка доступности нод через Ansible..."
	@ANSIBLE_PRIVATE_KEY_FILE=$(SSH_KEY_PATH) $(ANSIBLE_PLAYBOOK) -i ansible/learn-inventory/inventory.ini --list-hosts $(filter-out $@,$(MAKECMDGOALS))
