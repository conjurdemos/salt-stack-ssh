import os

import conjur

_client_layer_id = "salt-host-factory-1.0.1.dev/clients"

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
    appliance_url = os.environ['CONJUR_APPLIANCE_URL']
    account = os.environ.get('CONJUR_ACCOUNT', 'conjur')
    conjur.configure(account=account, appliance_url=appliance_url)
    return conjur.new_from_netrc()


def _provision_host(host_id):
    api = _conjur_api()
    host = api.create_host(host_id)
    api.layer(_client_layer_id).add_host(host)


def _setup_conjur_ssh(host_id, minion_id):
    pass
