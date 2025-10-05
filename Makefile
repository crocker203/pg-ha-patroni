# Makefile для pg-ha-patroni

# -----------------------------
# Переменные
# -----------------------------
VAGRANT_BIN := vagrant
ANSIBLE_PLAYBOOK := ansible-playbook
PG_HA_PATRONI_HOME := $(shell pwd)   # Используем корень проекта для всех путей

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
	@command -v direnv >/dev/null 2>&1 || (echo "⚠️  direnv не установлен. Установите через 'sudo apt install direnv'" && exit 1)
	@command -v vagrant >/dev/null 2>&1 || (echo "⚠️  Vagrant не установлен. Скачайте с https://www.vagrantup.com/downloads/" && exit 1)
	@command -v git >/dev/null 2>&1 || (echo "⚠️  Git не установлен. Установите git и повторите." && exit 1)

	# Запуск скрипта инициализации
	@bash scripts/init/init.sh

# -----------------------------
# Libvirt storage pool для Vagrant
# -----------------------------
.PHONY: init-pool
init-pool:
	@echo "⚙️ Создаём libvirt storage pool 'vagrant_images'..."
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) scripts/init/setup_libvirt_pool.sh

# -----------------------------
# Управление Vagrant с аргументами
# -----------------------------
.PHONY: up halt destroy db1 db2 consul

up: init-pool
	@echo "📦 Поднимаем кластер..."
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) $(VAGRANT_BIN) up $(filter-out $@,$(MAKECMDGOALS))

halt:
	@echo "⏸️ Останавливаем кластер..."
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) $(VAGRANT_BIN) halt $(filter-out $@,$(MAKECMDGOALS))

destroy:
	@echo "💣 Удаляем кластер..."
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) $(VAGRANT_BIN) destroy -f $(filter-out $@,$(MAKECMDGOALS))

# Пустые цели для VM, чтобы Make не ругался на неизвестные цели
db1 db2 consul:
	@:

# -----------------------------
# SSH доступ к нодам с аргументами
# -----------------------------
.PHONY: ssh
ssh:
	@echo "🔑 Подключаемся к VM через Vagrant SSH..."
	@PG_HA_PATRONI_HOME=$(PG_HA_PATRONI_HOME) $(VAGRANT_BIN) ssh $(filter-out $@,$(MAKECMDGOALS))

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
.PHONY: db
db:
	@:
