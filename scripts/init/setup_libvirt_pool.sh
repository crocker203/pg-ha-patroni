#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Пути и пул
# -----------------------------
POOL_NAME="vagrant_images"
POOL_PATH="${PG_HA_PATRONI_HOME}/vagrant_images"

mkdir -p "$POOL_PATH"

# -----------------------------
# Определяем пользователя и группу libvirt/qemu
# -----------------------------
if id "libvirt-qemu" &>/dev/null; then
    LIBVIRT_USER="libvirt-qemu"
    LIBVIRT_GROUP="libvirt-qemu"
elif id "qemu" &>/dev/null; then
    LIBVIRT_USER="qemu"
    LIBVIRT_GROUP="qemu"
else
    echo "⚠️ Не найден пользователь для libvirt/qemu. Проверьте установку libvirt."
    exit 1
fi

echo "⚙️ Устанавливаем права на каталог $POOL_PATH для $LIBVIRT_USER:$LIBVIRT_GROUP"
sudo chown -R $LIBVIRT_USER:$LIBVIRT_GROUP "$POOL_PATH"
sudo chmod -R 770 "$POOL_PATH"

# -----------------------------
# Создаём и запускаем storage pool
# -----------------------------
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
