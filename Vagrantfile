require 'pathname'
require 'yaml'
# Load the .conjurrc and policy.json and parse the settings out of it so they can be propagated to the Salt master.
# The Conjur config is sent to the Salt master via /etc/conjur.conf
# The host identity is sent to the Salt master via /root/.netrc

conjurrc = ENV['CONJURRC'] || '.conjurrc'
appliance_url = YAML.load(File.read(conjurrc))['appliance_url']
conjur_pem = YAML.load(File.read(conjurrc))['cert_file']
policy = JSON.parse(File.read('policy.json'))
api_keys = policy['api_keys']
salt_host_id = api_keys.keys.select{|k| k.split(':')[1] == 'host'}[0]
policy_id = policy['policy']
layer_id = [ policy['policy'], 'clients' ].join('/')

host_id = salt_host_id.split(':')[-1]
host_login = [ 'host', host_id ].join('/')
host_api_key = api_keys[salt_host_id]

File.write('salt_netrc', <<NETRC)
machine #{appliance_url}/authn
  login #{host_login}
  password #{host_api_key}
NETRC

File.write('salt/master.d/conjur.conf', <<CONJUR)
conjur_layer_default: #{layer_id}
conjur_host_prefix: #{policy_id}
CONJUR

BASE_BOX="http://cloud-images.ubuntu.com/vagrant"
PRECISE64_URL="#{BASE_BOX}/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

begin
  require 'vagrant-vbguest'
rescue LoadError => ex
  puts "Missing vagrant-vbguest plugin, you might want to install it"
end

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = PRECISE64_URL

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.ssh.forward_agent = true

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    override.ssh.private_key_path = ENV['SSH_PRIVATE_KEY_PATH']
  end

  config.vm.define :"salt" do |master|
    master.vm.network "private_network", ip: "10.47.94.2"
    master.vm.hostname = "salt"
    master.vm.synced_folder "salt/master.d", "/etc/salt/master.d"
    master.vm.synced_folder "srv/runners", "/srv/runners"
    master.vm.synced_folder "srv/reactor", "/srv/reactor"
    master.vm.synced_folder "srv/salt", "/srv/salt"

    master.vm.provision :file, source: "salt_netrc", destination: "/tmp/salt_netrc"
    master.vm.provision :file, source: conjurrc, destination: "/tmp/conjur.conf"
    master.vm.provision :file, source: conjur_pem, destination: "/tmp/#{Pathname.new(conjur_pem).basename.to_s}" if conjur_pem

    master.vm.provision :shell, path: "salt-install.sh"

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
    client.vm.provision :salt
    client.vm.provision :shell, inline: "sudo salt-call event.fire_master '{}' 'conjur/register'"
  end
end
