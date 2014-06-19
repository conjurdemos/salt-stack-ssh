include:
  - chef-solo

/var/chef/conjur-ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

/var/chef/roles/conjur-ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

/var/chef/roles/conjur-ssh.json:
  file.managed:
    - source: salt://conjur/conjur-ssh.json
    - user: root
    - group: root
    - mode: 0600
    - require:
      - file: /var/chef/roles/conjur-ssh

/etc/chef/solo.rb:
  file.managed:
    - source: salt://conjur/chef-solo.rb
    - user: root
    - group: root

conjur-ssh-cookbooks:
  archive:
    - extracted
    - name: /var/chef/conjur-ssh
    - source: salt://conjur/conjur-ssh-v1.1.0.tar.gz
    - archive_format: tar
    - tar_options: z
    - if_missing: /var/chef/conjur-ssh/cookbooks
    - require:
      - file: /var/chef/conjur-ssh

chef-solo -o role[conjur-ssh]:
  cmd.run:
    - require:
      - sls: chef-solo
      - file: /var/chef/roles/conjur-ssh.json
      - file: /etc/chef/solo.rb
      - archive: conjur-ssh-cookbooks
