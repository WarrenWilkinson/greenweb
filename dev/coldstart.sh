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
sudo sh bootstrap-salt.sh -L -M -A 127.0.0.1 -i vmhost -x python3

# 'Fix' Salt.
# https://github.com/saltstack/salt/issues/50679
sudo sed -i 's/lxc.network/lxc.net.0/g' /usr/lib/python*/dist-packages/salt/modules/lxc.py
# https://github.com/saltstack/salt/issues/52219
sudo sed -i 's/ntf.write(self.as_string())/ntf.write(salt.utils.stringutils.to_bytes(self.as_string()))/' /usr/lib/python*/dist-packages/salt/modules/lxc.py
#sudo systemctl restart salt-master

# Connect local client to local master
# echo "master: localhost" | sudo tee /etc/salt/minion.d/99-master-address.conf
# echo "id: vmhost" | sudo tee /etc/salt/minion.d/01-minion-id.conf
sudo systemctl restart salt-minion
sleep 60
sudo salt-key -y -a vmhost
sleep 60

echo "Bootstrap Phase 1: Preparing Host"
echo "########################################"
# Finish setup, run twice because it seems to be necessary
set +e
sudo salt vmhost saltutil.refresh_pillar
sudo salt 'vmhost' state.highstate
set -e
sudo salt vmhost saltutil.refresh_pillar
sudo salt 'vmhost' state.highstate
sleep 15

echo "Bootstrap Phase 2: Setup Bootstrap DNS"
echo "########################################"

# Predownload the template
sudo lxc-create --template download -n downloaded -- --no-validate -d ubuntu -r focal -a amd64

# Create the container this way, without bootstrapping because
# internet isn't going to work out of the box. Set it up on the
# special DNS ip address (which the host container is setup to query
# from).
sudo salt vmhost lxc.create bootdns profile=standard_focal network_profile=standard_net nic_opts="{eth0: {ipv4.address: 10.0.3.2/24, gateway: 10.0.3.1}}"

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
sudo lxc-stop bootdns
sudo lxc-start bootdns
sleep 10
sudo lxc-attach bootdns -- rm -f /etc/resolv.conf
sudo lxc-attach bootdns -- sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
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

sudo salt 'vmhost' lxc.init salt profile=standard_focal network_profile=standard_net bootstrap_args="-L -M -A salt -x python3"

# Create a space to mount libvirt into it.
sudo lxc-attach --name=salt -- mkdir /opt/libvirt

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

# KVM mounts
lxc.mount.entry = /var/run/libvirt opt/libvirt none ro,bind 0 0

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

# Stop the old master, and connect vmhost to the new one.
sudo rm /etc/salt/pki/minion/minion_master.pub
sudo rm /etc/salt/minion.d/99-master-address.conf
sudo systemctl restart salt-minion
sudo systemctl stop salt-master
sudo systemctl disable salt-master

# Turn off dnsseq on resolved.
sudo sed -e 's/^DNSSEC=yes$/DNSSEC=no/' -i /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

sleep 60
$salt-key -y -a vmhost
sleep 60

echo "Bootstrap Phase 4: Create New DNS server"
echo "########################################"

$salt-cloud -p lxc-focal dns

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
# vmhost, dns, and salt.
sleep 60
$salt '*' test.ping

echo "Bootstrap Phase 5: Orchestrating Cloud"
echo "########################################"

# Spin up all the remaining servers
$salt 'salt' state.highstate # To install libvirt
$salt-cloud -y -m /srv/salt/_orchestrate/mapfile

# Reboot docker so it gets it's new IP (hostname is set after cloud-init has an IP).
sudo virsh reboot docker
sleep 120

sudo virsh autostart docker
$salt '*' test.ping
$salt 'postgresql' state.highstate
$salt 'docker' state.sls hydra.migrate
$salt '*' state.highstate
$salt 'docker' state.sls hydra.provision

#$salt-run state.orchestrate _orchestrate.monitoring
