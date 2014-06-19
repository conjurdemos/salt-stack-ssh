#!/bin/bash -e
cp /tmp/conjur.conf /etc/
cp /tmp/conjur*.pem /etc/
cp /tmp/salt_netrc /root/.netrc

chmod 0600 /root/.netrc

apt-get update
apt-get install -y git python-setuptools

cd /opt

if [ ! -d "conjur-api-python" ]; then
    git clone https://github.com/conjurinc/api-python.git conjur-api-python
    cd conjur-api-python
else
    cd conjur-api-python
    git pull
fi

python setup.py install

mkdir -p /var/hosts
curl -L -o /srv/salt/conjur/conjur-ssh-v1.1.0.tar.gz https://github.com/conjur-cookbooks/conjur-ssh/releases/download/v1.1.0/conjur-ssh-v1.1.0.tar.gz
