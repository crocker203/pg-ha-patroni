#!/bin/bash

# Скрипт создания роли Ansible bootstrap
# Использование: ./create_bootstrap_role.sh /path/to/ansible/roles

set -e

ROLES_DIR="$1"

if [ -z "$ROLES_DIR" ]; then
    echo "Ошибка: Укажите путь к директории ролей Ansible"
    echo "Использование: $0 /path/to/ansible/roles"
    exit 1
fi

BOOTSTRAP_DIR="$ROLES_DIR/bootstrap"

echo "Создание роли bootstrap в $BOOTSTRAP_DIR"

# Создаем структуру директорий
mkdir -p "$BOOTSTRAP_DIR/tasks"

# Создаем основной файл задач с тегами
cat > "$BOOTSTRAP_DIR/tasks/main.yml" << 'EOF'
---
- name: Установка Python и системных утилит
  package:
    name:
      - python3
      - python3-pip
      - jq
      - telnet
      - nano
    state: present
  tags: packages

- name: Установка EPEL репозитория
  package:
    name: epel-release
    state: present
  tags: epel

- name: Установка htop из EPEL
  package:
    name: htop
    state: present
  tags: monitoring

- name: Создание симлинка python -> python3 для совместимости
  file:
    src: /usr/bin/python3
    dest: /usr/bin/python
    state: link
  when: ansible_facts['os_family'] == "RedHat"
  tags: python
EOF

echo "Роль bootstrap успешно создана в $BOOTSTRAP_DIR"
echo ""
echo "Структура созданной роли:"
find "$BOOTSTRAP_DIR" -type f -print | sed "s|$ROLES_DIR/||"

echo ""
echo "Пример использования в playbook:"
cat << 'EOF'
---
- name: Базовая настройка серверов
  hosts: all
  become: yes
  roles:
    - bootstrap
EOF
