#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Установка системных зависимостей для pg-ha-patroni..."

# Определяем дистрибутив
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "⚠️ Не удалось определить дистрибутив Linux"
    exit 1
fi

echo "ℹ️ Определён дистрибутив: $DISTRO"

# -----------------------------
# Установка для Ubuntu/Debian
# -----------------------------
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    sudo apt update
    sudo apt install -y \
        git \
        vagrant \
        python3 \
        python3-pip \
        direnv \
        libvirt-clients \
        libvirt-daemon-system \
        qemu \
        nano

# -----------------------------
# Установка для RHEL/CentOS/Oracle Linux
# -----------------------------
elif [[ "$DISTRO" == "rhel" || "$DISTRO" == "centos" || "$DISTRO" == "ol" ]]; then
    sudo yum install -y epel-release
    sudo yum install -y \
        git \
        vagrant \
        python3 \
        python3-pip \
        direnv \
        libvirt \
        qemu-kvm \
        nano

else
    echo "⚠️ Дистрибутив $DISTRO не поддерживается автоматически. Установите зависимости вручную."
    exit 1
fi

echo "✅ Системные пакеты установлены."
