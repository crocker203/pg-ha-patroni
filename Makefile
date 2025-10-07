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

.PHONY: ssh
ssh:
	@echo "🔑 Подключаемся к VM через SSH..."
	@$(VAGRANT_BIN) ssh $(filter-out $@,$(MAKECMDGOALS))

# -----------------------------
# Ansible
# -----------------------------
# -----------------------------
# Ansible: проверка подключения / выполнение плейбука
# -----------------------------
.PHONY: ansible

ANSIBLE_INVENTORY := $(PG_HA_PATRONI_HOME)/ansible/learn-inventory/inventory.ini
ANSIBLE_USER := vagrant
ANSIBLE_PRIVATE_KEY := $(SSH_KEY_PATH)

ansible:
	@TARGET=$${1:-all}; \
	echo "🔎 Проверка подключения к хосту ansible $$TARGET ..."; \
	ansible $$TARGET -i $(ANSIBLE_INVENTORY) -u $(ANSIBLE_USER) --private-key=$(ANSIBLE_PRIVATE_KEY) -m ping



.PHONY: playbook

playbook:
	@# Берём первый аргумент как playbook
	@PLAYBOOK=$(filter-out $@,$(MAKECMDGOALS) | head -n1); \
	if [ -z "$$PLAYBOOK" ]; then \
		echo "❌ Укажите playbook после make playbook"; \
		exit 1; \
	fi; \
	# Остальные аргументы — это хосты
	TARGETS=$(filter-out $$PLAYBOOK,$(filter-out $@,$(MAKECMDGOALS))); \
	if [ -z "$$TARGETS" ]; then TARGETS=all; fi; \
	echo "🎯 Запуск playbook $$PLAYBOOK на хостах: $$TARGETS"; \
	ANSIBLE_PRIVATE_KEY_FILE=$(SSH_KEY_PATH) \
		ansible-playbook $$PLAYBOOK -i $(PG_HA_PATRONI_HOME)/ansible/learn-inventory/inventory.ini \
		-u vagrant --private-key=$(SSH_KEY_PATH) -l "$$TARGETS"

# Чтобы make не ругался на аргументы (db1, consul и т.д.)
db1 db2 consul:
	@:

