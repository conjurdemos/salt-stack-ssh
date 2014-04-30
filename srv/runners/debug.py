def echo(data):
    with open('/tmp/debug', 'a') as f:
        f.write('[debug] {0}\n'.format(data))
