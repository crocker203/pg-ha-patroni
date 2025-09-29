Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle8"

  # ⚠️ Разрешаем Vagrant использовать дефолтный ключ при старте
  config.ssh.insert_key = true

  # VM1: Consul
  config.vm.define "consul" do |consul|
    consul.vm.hostname = "consul"
    consul.vm.network "private_network", ip: "192.168.121.10"
    consul.vm.provider :libvirt do |lv|
      lv.memory = 512
      lv.cpus = 1
    end
    consul.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/home/vagrant/id_ed25519.pub"
    consul.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cat /home/vagrant/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
      chown -R vagrant:vagrant /home/vagrant/.ssh
      chmod 600 /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  # VM2: PostgreSQL #1
  config.vm.define "db1" do |db1|
    db1.vm.hostname = "db1"
    db1.vm.network "private_network", ip: "192.168.121.11"
    db1.vm.provider :libvirt do |lv|
      lv.memory = 1024
      lv.cpus = 1
    end
    db1.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/home/vagrant/id_ed25519.pub"
    db1.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cat /home/vagrant/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
      chown -R vagrant:vagrant /home/vagrant/.ssh
      chmod 600 /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  # VM3: PostgreSQL #2
  config.vm.define "db2" do |db2|
    db2.vm.hostname = "db2"
    db2.vm.network "private_network", ip: "192.168.121.12"
    db2.vm.provider :libvirt do |lv|
      lv.memory = 1024
      lv.cpus = 1
    end
    db2.vm.provision "file", source: "~/.ssh/id_ed25519.pub", destination: "/home/vagrant/id_ed25519.pub"
    db2.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cat /home/vagrant/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
      chown -R vagrant:vagrant /home/vagrant/.ssh
      chmod 600 /home/vagrant/.ssh/authorized_keys
    SHELL
  end
end
