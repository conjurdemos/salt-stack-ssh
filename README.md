Salt Host Factory Demo
======================

A Conjur demo which demonstrates the use of SaltStack as a Host Factory.

The demo launches a Salt master and a client VM. The client VM uses the Salt master to obtain a 
host identity, and then configures itself for Conjur SSH.

Once this configuration is complete:

* User 'otto' can login and admin the client VM
* User 'donna' can login, but not admin, the client VM

Usage
-----

Initialize and configure the Conjur service.

```bash
conjur init -f .conjurrc
```

Generate the permissions model. The context is saved to policy.json, which used by the web service and by the 
cucumber client testing code.

```bash
bundle install
bundle exec conjur policy:load -c policy.json policy.rb
```

Start Vagrant

```bash
vagrant up
```

Register and configure the minion. You'll run three terminals: one to tail the master, one to tail the client,
and one to run commands.

## Terminal 1

Tail the master:

```bash
vagrant ssh salt -c "sudo tail -f /var/log/salt/master"
```

## Terminal 2

Tail the minion:

```bash
vagrant ssh client -c "sudo tail -f /var/log/salt/minion"
```

## Terminal 3

Register the client VM:

```bash
vagrant ssh client -c "sudo salt-call event.fire_master 'no-arg' 'conjur/register'"
```

Login

```
ssh -i ./ssh/otto_id_rsa "otto@salt-host-factory-1.0"@client -c "id ; sudo ls /etc"

ssh -i ./ssh/donna_id_rsa "donna@salt-host-factory-1.0"@client -c "id ; ls /etc"
```
