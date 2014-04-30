def echo(payload):
    with open('/tmp/debug', 'a') as f:
        f.write('[debug] {0}\n'.format(payload))
