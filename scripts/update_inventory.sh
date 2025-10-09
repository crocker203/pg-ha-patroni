#!/usr/bin/env bash
set -euo pipefail

# --- Параметры ---
INVENTORY_FILE="${1:-}"
[ -z "$INVENTORY_FILE" ] && { echo "❌ Не указан путь до inventory.ini"; exit 1; }

ROOT_DIR="${PG_HA_PATRONI_HOME:-$(pwd)}"
TOPOLOGY_FILE="$ROOT_DIR/topology/nodes.yml"

export VAGRANT_CWD="$ROOT_DIR"

mkdir -p "$(dirname "$INVENTORY_FILE")"
TMP_FILE=$(mktemp)
TMP_DIR=$(mktemp -d)
trap "rm -f $TMP_FILE; rm -rf $TMP_DIR" EXIT

echo "🔹 ROOT_DIR=$ROOT_DIR"
echo "🔹 TOPOLOGY_FILE=$TOPOLOGY_FILE"
echo "🔹 INVENTORY_FILE=$INVENTORY_FILE"

# --- Парсим nodes.yml вручную ---
declare -A NODE_GROUP
declare -A NODE_IP
current_node=""
current_group=""
while read -r line; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//')  # убираем отступы
    case "$line" in
        -\ name:*)
            current_node=$(echo "$line" | cut -d' ' -f3)
            ;;
        group:*)
            current_group=$(echo "$line" | cut -d' ' -f2)
            NODE_GROUP["$current_node"]="$current_group"
            ;;
        ip:*)
            ip_val=$(echo "$line" | cut -d' ' -f2)
            [[ "$ip_val" != "null" ]] && NODE_IP["$current_node"]="$ip_val"
            ;;
    esac
done < "$TOPOLOGY_FILE"

echo "🔹 Nodes from topology:"
for n in "${!NODE_GROUP[@]}"; do
    echo "  $n -> group=${NODE_GROUP[$n]}, ip=${NODE_IP[$n]:-unset}"
done

# --- Получаем список реально поднятых VM ---
active_nodes=$(vagrant global-status --prune | awk -v cwd="$VAGRANT_CWD" '$5==cwd && $4=="running" {print $2}')

echo "🔹 Active nodes detected:"
for n in $active_nodes; do
    echo "  $n"
done

# --- Ждём IP и формируем inventory ---
for node in $active_nodes; do
    group_name="${NODE_GROUP[$node]}"
    
    if [[ -n "${NODE_IP[$node]:-}" ]]; then
        ip="${NODE_IP[$node]}"
        echo "🔹 Using static IP for $node -> $ip"
    else
        echo "🔹 Waiting for dynamic IP for $node..."
        ip=""
        for i in {1..60}; do
            ip=$(vagrant ssh-config "$node" 2>/dev/null | awk '/HostName/ {print $2}' || true)
            [[ -n "$ip" ]] && break
            sleep 1
        done
        if [[ -z "$ip" ]]; then
            echo "❌ Не удалось получить IP для ноды $node"
            continue
        else
            echo "🔹 Got dynamic IP for $node -> $ip"
        fi
    fi

    echo "$node ansible_host=$ip" >> "$TMP_DIR/$group_name"
done

# --- Формируем inventory.ini ---
for group_file in "$TMP_DIR"/*; do
    group_name=$(basename "$group_file")
    echo "[$group_name]" >> "$TMP_FILE"
    cat "$group_file" >> "$TMP_FILE"
    echo "" >> "$TMP_FILE"
done

# Обновляем inventory.ini только если изменилось
if ! diff -q "$TMP_FILE" "$INVENTORY_FILE" >/dev/null 2>&1; then
    echo "🔄 Обновляем inventory.ini"
    cp "$TMP_FILE" "$INVENTORY_FILE"
else
    echo "✅ Inventory актуален"
fi

echo "✅ Готово: $INVENTORY_FILE"
