# Makefile для pg-ha-patroni

VAGRANT_BIN := vagrant
ANSIBLE_PLAYBOOK := ansible-playbook
PG_HA_PATRONI_HOME := $(shell pwd)

# Ключи
SSH_PRIVATE_KEY := $(PG_HA_PATRONI_HOME)/.ssh/id_ed25519
SSH_PUBLIC_KEY  := $(PG_HA_PATRONI_HOME)/.ssh/id_ed25519.pub

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

	# Генерация ключей, если отсутствуют
	@if [ ! -f "$(SSH_PRIVATE_KEY)" ]; then \
		echo "🔑 Генерируем SSH ключи для Vagrant/Ansible..."; \
		mkdir -p $(PG_HA_PATRONI_HOME)/.ssh; \
		ssh-keygen -t ed25519 -f $(SSH_PRIVATE_KEY) -N "" -q; \
	fi

	# Устанавливаем переменные окружения для Ansible
	@echo "export ANSIBLE_PRIVATE_KEY_FILE=$(SSH_PRIVATE_KEY)" > $(PG_HA_PATRONI_HOME)/.envrc
	@echo "export PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME)" >> $(PG_HA_PATRONI_HOME)/.envrc
	@echo "✅ SSH ключи и окружение готовы. Выполните 'direnv allow'"

	# Выполняем скрипт инициализации проекта
	@bash scripts/init/init.sh

.PHONY: up halt destroy db1 db2 consul

up:
	@echo "📦 Поднимаем кластер..."
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) SSH_PRIVATE_KEY=$(SSH_PRIVATE_KEY) SSH_PUBLIC_KEY=$(SSH_PUBLIC_KEY) $(VAGRANT_BIN) up $(filter-out $@,$(MAKECMDGOALS))

halt:
	@echo "⏸️ Останавливаем кластер..."
	@$(VAGRANT_BIN) halt $(filter-out $@,$(MAKECMDGOALS))

destroy:
	@echo "💣 Удаляем кластер..."
	@$(VAGRANT_BIN) destroy -f $(filter-out $@,$(MAKECMDGOALS))

.PHONY: ssh
ssh:
	@echo "🔑 Подключаемся к VM через SSH..."
	@$(VAGRANT_BIN) ssh $(filter-out $@,$(MAKECMDGOALS))

# -----------------------------
# Ansible
# -----------------------------
ANSIBLE_INVENTORY := $(PG_HA_PATRONI_HOME)/ansible/learn-inventory/inventory.ini
ANSIBLE_USER := vagrant

.PHONY: ansible
ansible:
	@TARGET=$(filter-out $@,$(MAKECMDGOALS)); \
	if [ -z "$$TARGET" ]; then TARGET=all; fi; \
	echo "🔎 Проверка подключения к хосту ansible $$TARGET ..."; \
	ansible $$TARGET -i $(ANSIBLE_INVENTORY) -u $(ANSIBLE_USER) --private-key=$(SSH_PRIVATE_KEY) -m ping

.PHONY: playbook
playbook:
	@PLAYBOOK=$(filter-out $@,$(MAKECMDGOALS) | head -n1); \
	if [ -z "$$PLAYBOOK" ]; then \
		echo "❌ Укажите playbook после make playbook"; \
		exit 1; \
	fi; \
	TARGETS=$(filter-out $$PLAYBOOK,$(filter-out $@,$(MAKECMDGOALS))); \
	if [ -z "$$TARGETS" ]; then TARGETS=all; fi; \
	echo "🎯 Запуск playbook $$PLAYBOOK на хостах: $$TARGETS"; \
	ansible-playbook $$PLAYBOOK -i $(ANSIBLE_INVENTORY) -u $(ANSIBLE_USER) --private-key=$(SSH_PRIVATE_KEY) -l "$$TARGETS"

# Заглушки, чтобы make не ругался на аргументы
db1 db2 consul:
	@:
