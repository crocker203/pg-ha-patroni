Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"
  config.ssh.insert_key = true

  # Пути
  PUB_KEY_PATH = File.expand_path("~/.ssh/id_ed25519.pub")
  IMAGES_DIR = "vagrant_images"  # относительный путь
  Dir.mkdir(IMAGES_DIR) unless Dir.exist?(IMAGES_DIR)

  # Helper для конфигурации VM
  def setup_node(node, ip:, memory:, cpus:, pub_key:)
    node.vm.network "private_network", ip: ip, auto_config: true
  
    node.vm.provider :libvirt do |lv|
      lv.memory = memory
      lv.cpus = cpus
  
      # Используем пул default
      lv.storage :file,
        size: '10G',
        name: "#{node.vm.hostname}.img",
        pool: "default"
    end
  
    node.vm.provision "shell", path: File.join(ENV['PG_HA_PATRONI_HOME'], "scripts/provision.sh"), args: [pub_key]
  end

  # VM1: Consul
  config.vm.define "consul" do |consul|
    consul.vm.hostname = "consul"
    setup_node(
      consul,
      ip: ENV.fetch("CONSUL_IP", "192.168.121.10"),
      memory: ENV.fetch("CONSUL_MEM", 512).to_i,
      cpus: ENV.fetch("CONSUL_CPU", 1).to_i,
      pub_key: PUB_KEY_PATH
    )
  end

  # VM2: PostgreSQL #1
  config.vm.define "db1" do |db1|
    db1.vm.hostname = "db1"
    setup_node(
      db1,
      ip: ENV.fetch("DB1_IP", "192.168.121.11"),
      memory: ENV.fetch("DB_MEM", 1024).to_i,
      cpus: ENV.fetch("DB_CPU", 1).to_i,
      pub_key: PUB_KEY_PATH
    )
  end

  # VM3: PostgreSQL #2
  config.vm.define "db2" do |db2|
    db2.vm.hostname = "db2"
    setup_node(
      db2,
      ip: ENV.fetch("DB2_IP", "192.168.121.12"),
      memory: ENV.fetch("DB_MEM", 1024).to_i,
      cpus: ENV.fetch("DB_CPU", 1).to_i,
      pub_key: PUB_KEY_PATH
    )
  end
end
