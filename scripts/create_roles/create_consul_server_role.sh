#!/bin/bash
set -e

ROLE_NAME="consul_server"
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
- name: Установить зависимости
  package:
    name: "{{ consul_dependencies }}"
    state: present
  become: yes

- name: Создать группу для Consul
  group:
    name: "{{ consul_group }}"
    state: present
  become: yes

- name: Создать пользователя для Consul
  user:
    name: "{{ consul_user }}"
    group: "{{ consul_group }}"
    system: yes
    shell: /sbin/nologin
  become: yes

- name: Создать директорию данных Consul
  file:
    path: "{{ consul_data_dir }}"
    state: directory
    owner: "{{ consul_user }}"
    group: "{{ consul_group }}"
    mode: "0755"
  become: yes

- name: Создать директорию конфигурации Consul
  file:
    path: "{{ consul_config_dir }}"
    state: directory
    owner: "{{ consul_user }}"
    group: "{{ consul_group }}"
    mode: "0755"
  become: yes

- name: Скачать Consul
  get_url:
    url: "{{ consul_download_url }}"
    dest: "/tmp/consul.zip"
    mode: '0644'
  become: yes

- name: Распаковать Consul
  unarchive:
    src: "/tmp/consul.zip"
    dest: "/usr/local/bin/"
    remote_src: yes
    mode: '0755'
  become: yes

- name: Создать конфиг Consul
  template:
    src: consul.hcl.j2
    dest: "{{ consul_config_dir }}/consul.hcl"
    owner: "{{ consul_user }}"
    group: "{{ consul_group }}"
    mode: "0644"
  notify:
    - restart consul
  become: yes

- name: Создать systemd unit для Consul
  copy:
    dest: /etc/systemd/system/consul.service
    content: |
      [Unit]
      Description=Consul Agent
      Wants=network-online.target
      After=network-online.target

      [Service]
      User={{ consul_user }}
      Group={{ consul_group }}
      ExecStart={{ consul_bin_path }} agent -config-dir={{ consul_config_dir }}
      ExecReload=/bin/kill -HUP $MAINPID
      KillMode=process
      Restart=on-failure
      LimitNOFILE=65536

      [Install]
      WantedBy=multi-user.target
  notify:
    - restart consul
  become: yes

- name: Enable and start Consul
  systemd:
    name: consul
    enabled: yes
    state: started
  become: yes
EOF

cat > $ROLE_DIR/handlers/main.yml <<'EOF'
---
- name: restart consul
  systemd:
    name: consul
    state: restarted
    enabled: yes
EOF

cat > $ROLE_DIR/defaults/main.yml <<'EOF'
---
consul_data_dir: "/var/lib/consul"
consul_server: true
consul_bootstrap_expect: 1
consul_ui: true
consul_user: "consul"
consul_group: "consul"
consul_bind_addr: "{{ ansible_host }}"
consul_advertise_addr: "{{ ansible_host }}"
consul_dependencies:
  - dnf
  - unzip
  - curl
EOF

cat > $ROLE_DIR/templates/consul.hcl.j2 <<'EOF'
data_dir = "{{ consul_data_dir }}"
server = {{ consul_server | lower }}
bootstrap_expect = {{ consul_bootstrap_expect }}
ui = {{ consul_ui | lower }}
bind_addr = "{{ consul_bind_addr }}"
advertise_addr = "{{ consul_advertise_addr }}"
EOF

cat > $ROLE_DIR/vars/main.yml <<'EOF'
---
consul_version: "1.16.0"
consul_download_url: "https://releases.hashicorp.com/consul/{{ consul_version }}/consul_{{ consul_version }}_linux_amd64.zip"
consul_bin_path: "/usr/local/bin/consul"
consul_config_dir: "/etc/consul.d"
EOF
echo "✅ Роль $ROLE_NAME создана по пути $ROLE_DIR"
