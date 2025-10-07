Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"
  config.ssh.insert_key = false

  # Пути
  ROOT_DIR = ENV['PG_HA_PATRONI_HOME'] || Dir.pwd
  SSH_KEY_PATH = ENV['SSH_KEY_PATH'] || File.join(ROOT_DIR, ".ssh/id_ed25519.pub")

  # Проверяем наличие ключа
  unless File.exist?(SSH_KEY_PATH)
    abort("❌ SSH ключ не найден: #{SSH_KEY_PATH}. Выполните 'make init'.")
  end

  # Копируем публичный ключ в VM до запуска provision.sh
  config.vm.provision "file",
    source: SSH_KEY_PATH,
    destination: "/tmp/pg_ha_patroni_id_ed25519.pub"

  # Helper для VM
  def setup_node(node, ip:, memory:, cpus:)
    node.vm.network "private_network", ip: ip, auto_config: true

    node.vm.provider :libvirt do |lv|
      lv.memory = memory
      lv.cpus = cpus
      lv.storage :file, size: '10G', name: "#{node.vm.hostname}.img", pool: "default"
    end

    # Запускаем стандартный скрипт
    node.vm.provision "shell",
      path: File.join(ENV['PG_HA_PATRONI_HOME'], "scripts/provision.sh"),
      args: ["/tmp/pg_ha_patroni_id_ed25519.pub"]
  end

  # Consul
  config.vm.define "consul" do |consul|
    consul.vm.hostname = "consul"
    setup_node(
      consul,
      ip: ENV.fetch("CONSUL_IP", "192.168.121.10"),
      memory: ENV.fetch("CONSUL_MEM", 512).to_i,
      cpus: ENV.fetch("CONSUL_CPU", 1).to_i
    )
  end

  # PostgreSQL #1
  config.vm.define "db1" do |db1|
    db1.vm.hostname = "db1"
    setup_node(
      db1,
      ip: ENV.fetch("DB1_IP", "192.168.121.11"),
      memory: ENV.fetch("DB_MEM", 1024).to_i,
      cpus: ENV.fetch("DB_CPU", 1).to_i
    )
  end

  # PostgreSQL #2
  config.vm.define "db2" do |db2|
    db2.vm.hostname = "db2"
    setup_node(
      db2,
      ip: ENV.fetch("DB2_IP", "192.168.121.12"),
      memory: ENV.fetch("DB_MEM", 1024).to_i,
      cpus: ENV.fetch("DB_CPU", 1).to_i
    )
  end
end
