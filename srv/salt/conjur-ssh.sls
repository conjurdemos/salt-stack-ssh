/var/chef/roles/conjur-ssh.json:
  file.managed:
    - source: salt://conjur/conjur-ssh.json
    - user: root
    - group: root
    - mode: 0600

/etc/chef/solo.rb:
  file.managed:
    - source: salt://conjur/chef-solo.rb
    - user: root
    - group: root

/var/chef/conjur-ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

conjur-ssh-cookbooks:
  archive:
    - extracted
    - name: /var/chef/conjur-ssh
    - source: salt://conjur/conjur-ssh-v1.0.0.tar.gz
    - archive_format: tar
    - tar_options: z
    - if_missing: /var/chef/conjur-ssh/cookbooks

chef-solo -o role[conjur-ssh]:
  cmd.run
