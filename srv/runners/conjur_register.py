import os
import yaml
import salt.config
import conjur

def register(host_id, payload):
    """
    Create and register a host identity with Conjur by adding it to the clients layer.

    host_id *must* be fully qualified
    """
    host = _provision_host(host_id, _client_layer_id())
    return { host.id, host.api_key }

def deregister(host_id):
    """
    Deregister a host from Conjur by removing it from the clients layer.
    """
    api = _conjur_api()
    api.layer(_client_layer_id()).remove_host(host_id)

def _conjur_api():
    conjur_conf = yaml.load(file('/etc/conjur.conf', 'r'))
    conjur.configure(account=conjur_conf['account'], appliance_url=conjur_conf['appliance_url'], verify_ssl=False)
    return conjur.new_from_netrc()

def _provision_host(host_id, layer_id):
    api = _conjur_api()
    host = api.create_host(host_id)
    api.layer(layer_id).add_host(host)
    return host

def _client_layer_id():
    return salt.config.master_config('/etc/salt/master')['conjur_layer_default']
