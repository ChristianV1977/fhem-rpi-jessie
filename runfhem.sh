#! /usr/bin/env bash
# Runs FHEM in foregroud for supervisord

set -eu

pidfile="/var/run/fhem/fhem.pid"
cd /opt/fhem

if [[ ! -f config/fhem.cfg ]]; then
cp fhem.cfg.org config/fhem.cfg
fi
if [[ ! -f fhem.cfg ]]; then
ln -s /opt/fhem/config/fhem.cfg /opt/fhem/fhem.cfg
fi
chown fhem /opt/fhem -R

if [[ ! -d config/yowsup-config ]]; then
mkdir config/yowsup-config
fi
if [[ ! -d /opt/yowsup-config ]]; then
ln -s /opt/fhem/config/yowsup-config /opt/yowsup-config
fi
chown fhem /opt/yowsup-config -R

if [[ ! -d config/pilight ]]; then
mkdir config/pilight
fi
if [[ ! -f config/pilight/config.json ]]; then
cp /etc/pilight/config.json.org /opt/fhem/config/pilight/config.json
fi
if [[ -f /etc/pilight/config.json ]]; then
rm /etc/pilight/config.json
fi
ln -s /opt/fhem/config/pilight/config.json /etc/pilight/config.json

# command=/usr/sbin/your-daemon
command=perl

# Proxy signals
function kill_app(){
    kill $(cat $pidfile)
    exit 0 # exit okay
}
trap "kill_app" SIGINT SIGTERM

# Launch daemon
$command fhem.pl fhem.cfg
sleep 2

# Loop while the pidfile and the process exist
while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
    sleep 0.5
done
exit 1000 # exit unexpected
