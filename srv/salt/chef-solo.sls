# Download and execute the Chef bootstrap bash script
curl:
  pkg:
    - installed

bootstrap_chef:
  cmd:
    - run
    - name: curl -L https://www.opscode.com/chef/install.sh | bash
    - unless: which 'chef-solo'
    - require:
      - pkg: curl