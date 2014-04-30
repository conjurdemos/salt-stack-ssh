/var/chef/roles/conjur.json:
  file.managed:
    - source: salt://conjur/conjur-role.json
    - user: root
    - group: root
    - mode: 0644
