#!/usr/bin/env bash
set -euo pipefail

POOL_NAME="vagrant_images"
POOL_PATH="${PG_HA_PATRONI_HOME}/vagrant_images"

mkdir -p "$POOL_PATH"

# Определяем пользователя libvirt-qemu
LIBVIRT_USER="qemu"   # часто uid:gid = 64055:993, зависит от системы
LIBVIRT_GROUP="kvm"

# Устанавливаем права для libvirt
sudo chown -R $LIBVIRT_USER:$LIBVIRT_GROUP "$POOL_PATH"
sudo chmod -R 770 "$POOL_PATH"

# Проверяем, существует ли уже пул
if ! virsh pool-info "$POOL_NAME" &>/dev/null; then
    echo "⚙️ Создаём libvirt storage pool $POOL_NAME..."
    virsh pool-define-as "$POOL_NAME" dir - - - - "$POOL_PATH"
    virsh pool-build "$POOL_NAME"
    virsh pool-start "$POOL_NAME"
    virsh pool-autostart "$POOL_NAME"
    echo "✅ Storage pool $POOL_NAME создан и запущен."
else
    echo "ℹ️ Storage pool $POOL_NAME уже существует."
fi
