# Overview

Demonstrates the use of SaltStack to register client VMs and configure them for Conjur SSH.

It works like this:

1. Create Conjur users "otto" (the ops guy) and "donna" (the developer)
1. Use Vagrant to launch a Salt master and a client VM
1. The client VM contacts the Salt master to register itself
1. The Salt master contacts Conjur to create a [Host](http://developer.conjur.net/reference/services/directory/host) identity to the client
1. The Salt master pushes the host identity to the client, and installs Conjur SSH using Salt states
1. "otto" can ssh to the client VM with root access using his personal private key
1. "donna" can ssh to the client VM with user-level access using her personal private key

# Conjur setup

Initialize and configure the Conjur service.

```
$ export CONJURAPI_LOG=stderr
$ conjur init -f .conjurrc
```

# Policy

Load the Conjur policy. The context is saved to policy.json, which used by the web service and by the 
cucumber client testing code.

```
$ conjur policy load -c policy.json policy.rb
```

Store otto and donna's login names in shell variables:

```
$ otto=`ruby -r json -e "puts JSON.load(File.read('policy.json'))['api_keys'].keys.find{|k| k.split(':')[-1] =~ /otto/}.split(':')[-1]"`
$ donna=`ruby -r json -e "puts JSON.load(File.read('policy.json'))['api_keys'].keys.find{|k| k.split(':')[-1] =~ /donna/}.split(':')[-1]"`
```

Show otto and donna's public keys, to confirm that they are loaded into Conjur:

```
$ conjur pubkeys show $otto
ssh-rsa AAAAB3NzaC1yc2EAAAADA...1yORpVcUmPFGZWzP/f/bZ otto@salt-host-factory
$ conjur pubkeys show $donna
ssh-rsa AAAAB3NzaC1yc2EAAAADA...kDnn1reRSeAv4sENHK56X donna@salt-host-factory
```

# Run the servers

Start Vagrant to bring up the Salt master and the client:

```
$ vagrant up
```

Save the client port number:

```
$ client_port=`vagrant ssh-config client | grep Port | cut -c 8-`
```

# Register the client

Now that the Salt master and the client VM are running, we will observe the Salt log files
in order to watch the registration and SSH configuration process taking place.

Run two terminals which tail the Salt log: one on the master, and one on the client.

## Terminal 1

Tail the master Salt log:

```
$ vagrant ssh salt -c "sudo tail -f /var/log/salt/master"
2014-06-19 15:01:38,095 [salt.master      ][INFO    ] Authentication accepted from client
2014-06-19 15:01:38,150 [salt.utils.event ][DEBUG   ] Gathering reactors for tag salt/auth
2014-06-19 15:01:38,238 [salt.master      ][INFO    ] Clear payload received with command _auth
2014-06-19 15:01:38,238 [salt.master      ][INFO    ] Authentication request from client
2014-06-19 15:01:38,238 [salt.master      ][INFO    ] Authentication accepted from client
2014-06-19 15:01:38,291 [salt.utils.event ][DEBUG   ] Gathering reactors for tag salt/auth
2014-06-19 15:01:38,349 [salt.master      ][INFO    ] AES payload received with command _mine
2014-06-19 15:01:59,892 [salt.fileserver  ][DEBUG   ] Updating fileserver cache
2014-06-19 15:01:59,896 [salt.fileserver  ][DEBUG   ] diff_mtime_map: the maps are the same
2014-06-19 15:01:59,896 [salt.utils.verify][DEBUG   ] This salt-master instance has accepted 1 minion keys.
```

## Terminal 2

Tail the minion Salt log:

```
$ vagrant ssh client -c "sudo tail -f /var/log/salt/minion"
2014-06-19 15:01:33,216 [salt.minion      ][INFO    ] Minion is starting as user 'root'
```

## Terminal 3

In a third terminal, we will fire the Salt event `conjur/register`. This event is handled on the Salt master
to create the Host record, push the Host identity to the client, and then apply the `conjur-ssh` state.

Register the client VM:

```
vagrant ssh client -c "sudo salt-call event.fire_master 'no-arg' 'conjur/register'"
```

# Login


## As "otto" the ops guy

```
$ ssh -i ./ssh/otto_id_rsa "$otto"@127.0.0.1 -p client_port
The authenticity of host '[localhost]:2201 ([127.0.0.1]:2201)' can't be established.
RSA key fingerprint is ef:16:74:16:15:60:58:bd:16:ba:43:53:14:5b:1b:52.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:2201' (RSA) to the list of known hosts.
Creating directory '/home/otto@yourname-yourhost-salt-host-factory-1-1'.
Welcome to Ubuntu 13.10 (GNU/Linux 3.11.0-14-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

  System information as of Thu Jun 19 15:47:58 UTC 2014

  System load:  0.0               Processes:           85
  Usage of /:   2.8% of 39.34GB   Users logged in:     1
  Memory usage: 35%               IP address for eth0: 10.0.2.15
  Swap usage:   0%                IP address for eth1: 10.47.94.3

  Graph this data and manage this system at:
    https://landscape.canonical.com/

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

New release '14.04' available.
Run 'do-release-upgrade' to upgrade to it.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
otto@yourname-yourhost-salt-host-factory-1-1@client:~$
```

Login is successful! Use the `id` command to show the uid and primary group:

```
otto@client:~$ id
uid=1402(otto@yourname-yourhost-salt-host-factory-1-1) gid=50000(conjurers) groups=50000(conjurers)
```

Now, test sudo capability:

```
otto@client:~$ sudo -i
root@client:~# 
```

## As "donna" the developer

```
$ ssh -i ./ssh/donna_id_rsa "$donna"@127.0.0.1 -p $client_port
ssh -i ./ssh/donna_id_rsa "$donna"@127.0.0.1 -p $client_port
The authenticity of host '[127.0.0.1]:2201 ([127.0.0.1]:2201)' can't be established.
RSA key fingerprint is ef:16:74:16:15:60:58:bd:16:ba:43:53:14:5b:1b:52.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[127.0.0.1]:2201' (RSA) to the list of known hosts.
Creating directory '/home/donna@yourself-yourhost-salt-host-factory-1-1'.
Welcome to Ubuntu 13.10 (GNU/Linux 3.11.0-14-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

  System information as of Thu Jun 19 16:09:06 UTC 2014

  System load:  0.0               Processes:           88
  Usage of /:   3.7% of 39.34GB   Users logged in:     1
  Memory usage: 33%               IP address for eth0: 10.0.2.15
  Swap usage:   0%                IP address for eth1: 10.47.94.3

  Graph this data and manage this system at:
    https://landscape.canonical.com/

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

New release '14.04' available.
Run 'do-release-upgrade' to upgrade to it.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

donna@yourself-yourhost-salt-host-factory-1-1@client:~$ id
uid=1403(donna@yourself-yourhost-salt-host-factory-1-1) gid=5000(users) groups=5000(users)
```

Test sudo capability:

```
donna@client $ sudo cat /etc/nslcd.conf | head -n 6
[sudo] password for donna@kgilpin-wm164-1b7-local-salt-host-factory-1-1: 
donna is not in the sudoers file.  This incident will be reported.
```
