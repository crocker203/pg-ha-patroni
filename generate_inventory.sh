#!/bin/bash
# Генерация ansible/inventory.ini из Vagrantfile

OUTFILE="ansible/inventory.ini"
mkdir -p ansible

cat > $OUTFILE <<EOF
[consul]
192.168.121.10

[db]
192.168.121.11
192.168.121.12
EOF

echo "✅ Inventory сгенерирован в $OUTFILE"
