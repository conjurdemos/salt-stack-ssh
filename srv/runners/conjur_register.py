import os
import re
import string
import yaml
import json
import salt.config
import salt.client
import conjur

def register(minion):
    """
    Create and register a host identity with Conjur by adding it to the clients layer.

    host_id *must* be fully qualified
    """
    host_id = string.join([_host_prefix(), minion], '/')
    fname = '%s.json'% re.sub("/", "_", host_id)

    host = _provision_host(host_id, _client_layer_id())
    api_key = None
    try:
        api_key = host.api_key
    except: AttributeError
        # pass
        
    host_json = None
    if api_key:
        conjur_conf = yaml.load(file('/etc/conjur.conf', 'r'))
        ssl_certificate = open(string.join(['/etc/', conjur_conf['cert_file']], ''), 'r').read()
        host_json = json.dumps({
          "conjur": {
            "host_identity": {
              "id": host.id,
              "api_key": api_key
            },
            "ssl_certificate": re.sub("\n", "\\n", ssl_certificate)
          }
        }, indent=2)
        file('/var/hosts/%s' % fname, 'w').write(host_json)
    else:
        host_json = open('/var/hosts/%s' % fname, 'r').read()

    local = salt.client.LocalClient()
    local.cmd([minion], 'cp.recv', [{minion: host_json}, '/etc/chef/solo.json'], expr_form='list')

def deregister(host_id):
    """
    Deregister a host from Conjur by removing it from the clients layer.
    """
    host_id = string.join([_host_prefix(), host_id], '/')
    api = _conjur_api()
    api.layer(_client_layer_id()).remove_host(host_id)

def _conjur_api():
    conjur_conf = yaml.load(file('/etc/conjur.conf', 'r'))
    conjur.configure(account=conjur_conf['account'], appliance_url=conjur_conf['appliance_url'], verify_ssl=False)
    return conjur.new_from_netrc()

def _provision_host(host_id, layer_id):
    api = _conjur_api()
    host = api.host(host_id)
    if not host.exists():
        host = api.create_host(host_id)
    api.layer(layer_id).add_host(host)
    return host

def _host_prefix():
    return salt.config.master_config('/etc/salt/master')['conjur_host_prefix']

def _client_layer_id():
    return salt.config.master_config('/etc/salt/master')['conjur_layer_default']
