#!/usr/bin/env bash
set -euo pipefail

PUB_KEY_PATH="${1:-/tmp/pg_ha_patroni_id_ed25519.pub}"

# Добавляем публичный ключ, если он передан и существует
if [[ -f "$PUB_KEY_PATH" ]]; then
    echo "🔑 Настраиваем SSH доступ..."
    mkdir -p /home/vagrant/.ssh
    cat "$PUB_KEY_PATH" >> /home/vagrant/.ssh/authorized_keys
    chmod 700 /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
else
    echo "⚠️ Публичный ключ не найден: $PUB_KEY_PATH (пропускаем настройку SSH)"
fi

# Установка nano (опционально)
#sudo dnf install -y nano

# Установка Python3, pip
#sudo dnf install -y python3 python3-pip

# Симлинк для совместимости с Ansible
if [ ! -f /usr/bin/python ] && [ -f /usr/bin/python3 ]; then
    sudo ln -s /usr/bin/python3 /usr/bin/python
fi
