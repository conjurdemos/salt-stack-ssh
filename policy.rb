policy "salt-host-factory-1.0.1.dev" do
  group "ops" do
    add_member user("otto")
  end
  
  group "developers" do
    add_member user("donna")
  end
  
  layer "salt-masters" do
    add_host host("salt-master/1")
  end

  layer "clients" do
    add_host host("client/1")
  end
end
