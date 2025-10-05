#!/usr/bin/env bash
set -euo pipefail

PUB_KEY="$1"

# Создаём .ssh и добавляем ключ
mkdir -p /home/vagrant/.ssh
cat "$PUB_KEY" >> /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys

# Установка nano (опционально)
sudo dnf install -y nano

# Установка Python3, pip
sudo dnf install -y python3 python3-pip

# Симлинк для совместимости с Ansible
if [ ! -f /usr/bin/python ] && [ -f /usr/bin/python3 ]; then
    sudo ln -s /usr/bin/python3 /usr/bin/python
fi
