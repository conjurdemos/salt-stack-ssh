`mkdir -p ssh`

policy "salt-host-factory-1.1.0.dev" do
  group "ops" do
    add_member otto = user("otto")
    
    unless File.exists?("ssh/otto_id_rsa.pub")
      puts "Creating pubkey for #{otto.login}"
      `ssh-keygen -q -N '' -f ssh/otto_id_rsa  -b 2048 -C "otto@salt-host-factory"`
      api.add_public_key otto.login, File.read('ssh/otto_id_rsa.pub')
    end
  end
  
  group "developers" do
    add_member donna = user("donna")

    unless File.exists?("ssh/donna_id_rsa.pub")
      puts "Creating pubkey for #{donna.login}"
      `ssh-keygen -q -N '' -f ssh/donna_id_rsa  -b 2048 -C "donna@salt-host-factory"`
      api.add_public_key donna.login, File.read('ssh/donna_id_rsa.pub')
    end
  end
  
  layer "salt-masters" do
    add_host host("salt-master/1")
    
    owns do
      layer "clients" do
        add_member "admin_host", group("ops")
        add_member "use_host", group("developers")
      end
    end
  end
end
