#!/bin/bash -e
mv /tmp/policy.json /var/
mv /tmp/conjur.conf /etc/
sudo mv /tmp/conjur*.pem /etc/

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
