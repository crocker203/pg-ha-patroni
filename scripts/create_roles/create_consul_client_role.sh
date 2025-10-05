#!/bin/bash
set -e

ROLE_NAME="consul_client"
ROLES_DIR="$HOME/pg-ha-patroni/ansible/playbook-library/roles"
ROLE_DIR="$ROLES_DIR/$ROLE_NAME"

if [ -d "$ROLE_DIR" ]; then
  echo "⚠️ Роль $ROLE_NAME уже существует в $ROLE_DIR"
  exit 0
fi

echo "📂 Создаём директории роли $ROLE_NAME ..."
mkdir -p $ROLE_DIR/{tasks,templates,files,vars,defaults,handlers}

# main.yml
cat > $ROLE_DIR/tasks/main.yml <<'EOF'
---
- name: Создать пользователя и директории для Consul
  ansible.builtin.user:
    name: consul
    shell: /sbin/nologin
    system: yes
    create_home: no

- name: Создать директории
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    owner: consul
    group: consul
    mode: '0755'
  loop:
    - /etc/consul.d
    - /var/lib/consul

- name: Скачать Consul
  ansible.builtin.get_url:
    url: "https://releases.hashicorp.com/consul/1.17.0/consul_1.17.0_linux_amd64.zip"
    dest: /tmp/consul.zip
    mode: '0644'

- name: Распаковать Consul
  ansible.builtin.unarchive:
    src: /tmp/consul.zip
    dest: /usr/local/bin/
    remote_src: yes
    mode: '0755'

- name: Конфигурация Consul client
  ansible.builtin.copy:
    dest: /etc/consul.d/consul.hcl
    content: |
      data_dir = "/var/lib/consul"
      bind_addr = "{{ ansible_host }}"
      client_addr = "0.0.0.0"
      advertise_addr = "{{ ansible_host }}"
      retry_join = ["{{ consul_server_ip }}"]

- name: Systemd unit
  ansible.builtin.copy:
    dest: /etc/systemd/system/consul.service
    content: |
      [Unit]
      Description=Consul Client Agent
      After=network-online.target
      Wants=network-online.target

      [Service]
      User=consul
      Group=consul
      ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
      ExecReload=/bin/kill -HUP $MAINPID
      Restart=on-failure
      LimitNOFILE=65536

      [Install]
      WantedBy=multi-user.target

- name: Включить и запустить consul
  ansible.builtin.systemd:
    name: consul
    state: started
    enabled: true
EOF

echo "✅ Роль $ROLE_NAME создана по пути $ROLE_DIR"
