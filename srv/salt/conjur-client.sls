/var/chef/roles/conjur.json:
  file.managed:
    - source: salt://conjur/conjur-role.json
    - user: root
    - group: root
    - mode: 0644

/etc/chef/solo.rb:
  file.managed:
    - source: salt://conjur/chef-solo.rb
    - user: root
    - group: root

/opt/conjur/embedded/ssl/certs:
  file.directory:
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

/var/chef:
  file.directory:
    - user: root
    - group: root
    - mode: 0755

conjur-ssh-cookbooks:
  archive:
    - extracted
    - name: /var/chef
    - source: salt://conjur/trusted-image.tar.gz
    - archive_format: tar
    - tar_options: z
    - if_missing: /var/chef/cookbooks

chef-solo -o role[conjur]:
  cmd.run
