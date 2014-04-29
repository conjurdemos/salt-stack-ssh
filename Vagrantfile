BASE_BOX="http://cloud-images.ubuntu.com/vagrant"
PRECISE64_URL="#{BASE_BOX}/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = PRECISE64_URL

  config.ssh.forward_agent = true

  config.vm.define :"salt" do |master|
    master.vm.network "private_network", ip: "10.47.94.2"
    master.vm.hostname = "salt"
    master.vm.synced_folder "srv/runners", "/srv/runners"
    master.vm.synced_folder "srv/reactor", "/srv/reactor"
    master.vm.synced_folder "srv/salt", "/srv/salt"

    master.vm.provision :salt do |salt|
      salt.verbose = true
  
      salt.no_minion = true
      salt.master_config = "salt/master"
      salt.install_master = true
    end
  end

  config.vm.define :"client" do |client|
    client.vm.network "private_network", ip: "10.47.94.3"
    client.vm.hostname = "client"

    client.vm.provision :file, source: "files/client/hosts", destination: "/tmp/hosts"
    client.vm.provision :shell, inline: "sudo mv /tmp/hosts /etc/hosts"

    client.vm.provision :salt do |salt|
      salt.verbose = true
      salt.run_highstate = true
    end
  end
end
