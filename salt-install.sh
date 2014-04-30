#!/bin/bash -e
mv /tmp/conjur.conf /etc/
mv /tmp/conjur*.pem /etc/
mv /tmp/salt_netrc /root/.netrc

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
