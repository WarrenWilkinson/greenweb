#!/bin/bash
# Bootstrap a basic machine into a salt master

set -x
set -e

# echo "Installing a few dependencies..."
# Install some dependencies
# sudo apt-get update
# sudo apt-get install -y python-pygit2 lxc zfsutils-linux python-pip

echo "Bootstrap Phase 0: Installing salt"
echo "########################################"
# Install salt master software with salt-cloud support
cd /tmp
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -L -M -A 127.0.0.1 -i vagrant.vm

# 'Fix' Salt.
# https://github.com/saltstack/salt/issues/50679
sudo sed -i 's/lxc.network/lxc.net.0/g' /usr/lib/python*/dist-packages/salt/modules/lxc.py
sudo systemctl restart salt-master

# Connect local client to local master
sleep 60
sudo salt-key -y -a vagrant.vm

echo "Bootstrap Phase 1: Preparing Host"
echo "########################################"
# Finish setup, run twice because it seems to be necessary
set +e
sudo salt 'vagrant.vm' state.highstate
set -e
sudo salt 'vagrant.vm' state.highstate
sleep 15

echo "Bootstrap Phase 2: Setup Bootstrap DNS"
echo "########################################"

# Predownload the template
sudo lxc-create --template download -n downloaded -- --no-validate -d ubuntu -r bionic -a amd64

# Create the container this way, without bootstrapping because
# internet isn't going to work out of the box. Set it up on the
# special DNS ip address (which the host container is setup to query
# from).
sudo salt vagrant.vm lxc.create bootdns profile=standard_bionic network_profile=standard_net nic_opts="{eth0: {ipv4.address: 10.0.3.2/24, gateway: 10.0.3.1}}"

# Fix the internet by getting rid of netplan, which attempts DHCP.
sudo lxc-start bootdns
sleep 10
sudo lxc-attach bootdns -- apt-get remove -y netplan.io
sudo lxc-stop bootdns
sudo lxc-start bootdns
sleep 10

# Install dnsmasq
sudo lxc-attach bootdns -- sudo systemctl stop systemd-resolved
sudo lxc-attach bootdns -- sudo systemctl disable systemd-resolved
sudo lxc-attach bootdns -- sed -i 's/^nameserver.*$/nameserver 8.8.8.8/g' /etc/resolv.conf
sudo lxc-attach bootdns -- apt-get update
sudo lxc-attach bootdns -- apt-get install -y dnsmasq
sudo lxc-attach bootdns -- sh -c 'echo "domain=greenweb.ca" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "local=/greenweb.ca/" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "expand-hosts" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "dhcp-range=10.0.3.70,10.0.3.100,12h" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "dhcp-authoritative" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "dhcp-option=option:router,10.0.3.1" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- systemctl restart dnsmasq

echo "Bootstrap Phase 3: Initialize the New Salt Master"
echo "########################################"

sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-L -M -A salt"

# For the dev session, Shutdown the saltmaster, add in appropriate
# mounts so we have all the salt files in the new saltmaster.
# in production, we'd manually pull from the git repo.
# echo "Step 2. Setup Saltmaster for development environment"
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/cloud.profiles.d
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/cloud.providers.d
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/master.d
sudo lxc-attach --name=salt -- mkdir /srv/salt
sudo lxc-attach --name=salt -- mkdir /srv/pillar
sudo lxc-stop salt
cat <<EOF | sudo tee -a /var/lib/lxc/salt/config

# Development Mounts
lxc.mount.entry = /etc/salt/cloud.profiles.d etc/salt/cloud.profiles.d none ro,bind 0 0
lxc.mount.entry = /etc/salt/cloud.providers.d etc/salt/cloud.providers.d none ro,bind 0 0
lxc.mount.entry = /etc/salt/master.d etc/salt/master.d none ro,bind 0 0
lxc.mount.entry = /srv/salt srv/salt none ro,bind 0 0
lxc.mount.entry = /srv/pillar srv/pillar none ro,bind 0 0
EOF

sudo lxc-start salt
salt="sudo lxc-attach --name=salt -- salt"
sleep 90
$salt-key -y -a salt

echo "Bootstrap Phase 4: Attach host to new Salt"
echo "########################################"

# Stop the old master, and connect vagrant.vm to the new one.
sudo rm /etc/salt/pki/minion/minion_master.pub
sudo rm /etc/salt/minion.d/99-master-address.conf
sudo systemctl restart salt-minion
sudo systemctl stop salt-master
sudo systemctl disable salt-master
sleep 30
$salt-key -y -a vagrant.vm
sleep 30

echo "Bootstrap Phase 4: Create New DNS server"
echo "########################################"

$salt-cloud -p lxc-bionic dns

$salt 'dns' state.highstate

# Shutdown the old DNS server.
sudo lxc-stop bootdns
sudo lxc-destroy bootdns

# Reboot it to use it's new static IP
sudo lxc-stop dns
sudo lxc-start dns
sleep 30

# Reboot the salt machine so it gets a new IP
# and added to the new DNS table.
sudo lxc-stop salt
sudo lxc-start salt

# Restart the salt-minion to reconnect
# to the salt master on it's new IP address.
sudo systemctl restart salt-minion

# Ping should work and return
# vagrant.vm, dns, and salt.
sleep 60
$salt '*' test.ping

echo "Bootstrap Phase 5: Orchestrating Cloud"
echo "########################################"

# Spin up all the remaining servers
$salt-cloud -y -m /srv/salt/_orchestrate/mapfile
$salt '*' test.ping
$salt '*' state.highstate
#$salt-run state.orchestrate _orchestrate.monitoring
