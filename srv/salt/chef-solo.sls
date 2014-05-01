# Download and execute the Chef bootstrap bash script
curl:
  pkg:
    - installed

bootstrap_chef:
  cmd:
    - run
    - name: curl -L https://www.opscode.com/chef/install.sh | bash
    - require:
      - pkg: curl
