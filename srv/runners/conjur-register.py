import os
import re
import yaml
import json
import salt.config
import conjur

_client_layer_id = "salt-host-factory-1.0.2.dev/clients"

def register(host_id, minion_id):
    """
    Create and register a host identity with Conjur by adding it to the clients layer.

    host_id *must* be fully qualified
    """
    _provision_host(host_id)
    _setup_conjur_ssh(host_id, minion_id)

def deregister(host_id):
    """
    Deregister a host from Conjur by removing it from the clients layer.
    """
    api = _conjur_api()
    api.layer(_client_layer_id).remove_host(host_id)

def _conjur_api():
    conjur_conf = yaml.load(file('/etc/conjur.conf', 'r'))
    policy = json.load(file('/var/policy.json'))
    api_keys = policy['api_keys']
    regex = re.compile('^([^\:]+):host:(.*)')
    host_identity = [m for k in api_keys.keys() for m in [regex.search(k)] if m][0]
    host_id = "host/%s" % host_identity.group(2)
    host_key = api_keys["%s:host:%s" % (host_identity.group(1), host_identity.group(2))]

    conjur.configure(account=conjur_conf['account'], appliance_url=conjur_conf['appliance_url'], verify_ssl=False)
    return conjur.new_from_key(host_id, host_key)

def _provision_host(host_id):
    api = _conjur_api()
    host = api.host(host_id)
    if not host.exists():
        host = api.create_host(host_id)
    api.layer(_client_layer_id).add_host(host)

def _setup_conjur_ssh(host_id, minion_id):
    pass
