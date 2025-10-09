require 'yaml'

Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"
  config.ssh.insert_key = false

  ROOT_DIR = ENV['PG_HA_PATRONI_HOME'] || Dir.pwd
  SSH_PRIVATE_KEY = ENV['SSH_PRIVATE_KEY'] || File.join(ROOT_DIR, ".ssh/id_ed25519")
  SSH_PUBLIC_KEY  = ENV['SSH_PUBLIC_KEY']  || File.join(ROOT_DIR, ".ssh/id_ed25519.pub")
  INVENTORY_PATH  = File.join(ROOT_DIR, "ansible/learn-inventory/inventory.ini")
  TOPOLOGY_FILE   = File.join(ROOT_DIR, "topology/nodes.yml")
  UPDATE_SCRIPT   = File.join(ROOT_DIR, "scripts/update_inventory.sh")

  abort("❌ SSH ключи не найдены") unless File.exist?(SSH_PRIVATE_KEY) && File.exist?(SSH_PUBLIC_KEY)
  abort("❌ Скрипт update_inventory.sh не найден") unless File.exist?(UPDATE_SCRIPT)

  nodes_def = YAML.load_file(TOPOLOGY_FILE)["nodes"]

  nodes_def.each do |node_def|
    config.vm.define node_def["name"] do |node|
      node.vm.hostname = node_def["name"]

      # Статический IP если указан, иначе DHCP
      if node_def["ip"] && !node_def["ip"].empty?
        node.vm.network "private_network", ip: node_def["ip"], auto_config: true
      else
        node.vm.network "private_network", type: "dhcp", auto_config: true
      end

      node.vm.provider :libvirt do |lv|
        lv.memory = node_def["memory"] || 1024
        lv.cpus   = node_def["cpus"] || 1
        lv.storage :file, size: '10G', name: "#{node.vm.hostname}.img", pool: "default"
      end

      node.vm.provision "file",
        source: SSH_PUBLIC_KEY,
        destination: "/tmp/pg_ha_patroni_id_ed25519.pub"

      node.vm.provision "shell",
        path: File.join(ROOT_DIR, "scripts/provision.sh"),
        args: ["/tmp/pg_ha_patroni_id_ed25519.pub"]
    end
  end

  # 🧩 Триггер после команды `vagrant up`
  config.trigger.after :up, type: :command do |trigger|
    trigger.name = "Обновление Ansible inventory (после всех поднятых нод)"
    trigger.run = {
      inline: "#{UPDATE_SCRIPT} #{INVENTORY_PATH}"
    }
  end
end
