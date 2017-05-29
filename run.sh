#!/bin/bash
# Run command for docker service fhem and sshd

# check if ssh-keys exists 
test -x /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server

# sshd
    # Create the PrivSep empty dir if necessary
    if [ ! -d /var/run/sshd ]; then
        mkdir /var/run/sshd
        chmod 0755 /var/run/sshd
    fi

echo "Current directory : $(pwd)"
echo "Environment RUNVAR: $RUNVAR"
echo "There are $# arguments: $@"

# make pidfile rundir for fhem (because /var/run  is tmpfs in ram)
if [ ! -d /var/run/fhem  ]; then
    mkdir /var/run/fhem
    chown -R fhem:root /var/run/fhem
fi

if [ -z "$1" ]; then
    echo "No argument supplied. Start supervisord and services."
	
	/etc/init.d/dbus start

    # nfsclient / rpcbind
    mkdir /run/sendsigs.omit.d
    service rpcbind start

    # autofs
    service autofs start

    service avahi-daemon  start
    service cron start
	
    # fhem start with supervisord 
    mkdir -p /var/log/supervisor
    /usr/bin/supervisord
  else
    echo "Execute: $1 "
    $1
fi


