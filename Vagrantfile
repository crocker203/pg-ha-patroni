Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"
  config.ssh.insert_key = false

  ROOT_DIR = ENV['PG_HA_PATRONI_HOME'] || Dir.pwd
  SSH_PRIVATE_KEY = ENV['SSH_PRIVATE_KEY'] || File.join(ROOT_DIR, ".ssh/id_ed25519")
  SSH_PUBLIC_KEY  = ENV['SSH_PUBLIC_KEY']  || File.join(ROOT_DIR, ".ssh/id_ed25519.pub")

  unless File.exist?(SSH_PRIVATE_KEY) && File.exist?(SSH_PUBLIC_KEY)
    abort("❌ SSH ключи не найдены: #{SSH_PRIVATE_KEY}, #{SSH_PUBLIC_KEY}. Выполните 'make init'.")
  end

  # Копируем публичный ключ в VM
  config.vm.provision "file",
    source: SSH_PUBLIC_KEY,
    destination: "/tmp/pg_ha_patroni_id_ed25519.pub"

  # Helper для VM
  def setup_node(node, ip:, memory:, cpus:)
    node.vm.network "private_network", ip: ip, auto_config: true

    node.vm.provider :libvirt do |lv|
      lv.memory = memory
      lv.cpus = cpus
      lv.storage :file, size: '10G', name: "#{node.vm.hostname}.img", pool: "default"
    end

    # Запускаем скрипт provision.sh
    node.vm.provision "shell",
      path: File.join(ENV['PG_HA_PATRONI_HOME'], "scripts/provision.sh"),
      args: ["/tmp/pg_ha_patroni_id_ed25519.pub"]
  end

  config.vm.define "consul" do |consul|
    consul.vm.hostname = "consul"
    setup_node(consul,
      ip: ENV.fetch("CONSUL_IP", "192.168.121.10"),
      memory: ENV.fetch("CONSUL_MEM", 512).to_i,
      cpus: ENV.fetch("CONSUL_CPU", 1).to_i
    )
  end

  config.vm.define "db1" do |db1|
    db1.vm.hostname = "db1"
    setup_node(db1,
      ip: ENV.fetch("DB1_IP", "192.168.121.11"),
      memory: ENV.fetch("DB_MEM", 1024).to_i,
      cpus: ENV.fetch("DB_CPU", 1).to_i
    )
  end

  config.vm.define "db2" do |db2|
    db2.vm.hostname = "db2"
    setup_node(db2,
      ip: ENV.fetch("DB2_IP", "192.168.121.12"),
      memory: ENV.fetch("DB_MEM", 1024).to_i,
      cpus: ENV.fetch("DB_CPU", 1).to_i
    )
  end
end
