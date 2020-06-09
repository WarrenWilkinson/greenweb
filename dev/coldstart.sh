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

echo "Bootstrap Phase 2: Bootstrap the internal DNS"
echo "########################################"

# Create the container this way, without bootstrapping
# because internet isn't going to work out of the box.
sudo salt vagrant.vm lxc.create dns profile=standard_bionic network_profile=standard_net nic_opts="{eth0: {ipv4.address: 10.0.3.2/24, gateway: 10.0.3.1}}"

# Fix the internet by getting rid of netplan, which attempts DHCP.
sudo lxc-start dns
sleep 10
sudo lxc-attach dns -- apt-get remove -y netplan.io
sudo lxc-stop dns
sudo lxc-start dns
sleep 10

# May also need to set packet forwarding in /proc here..

# Install dnsmasq
sudo lxc-attach dns -- sudo systemctl stop systemd-resolved
sudo lxc-attach dns -- sudo systemctl disable systemd-resolved
sudo lxc-attach dns -- sed -i 's/^nameserver.*$/nameserver 8.8.8.8/g' /etc/resolv.conf
sudo lxc-attach dns -- apt-get update
sudo lxc-attach dns -- apt-get install -y dnsmasq
sudo lxc-attach dns -- sh -c 'echo "dhcp-host=salt,10.0.3.3" >> /etc/dnsmasq.conf'
sudo lxc-attach dns -- sh -c 'echo "server=8.8.8.8" >> /etc/dnsmasq.conf'
sudo lxc-attach dns -- sh -c 'echo "server=8.8.4.4" >> /etc/dnsmasq.conf'
sudo lxc-attach dns -- sh -c 'echo "dhcp-range=10.0.3.70,10.0.3.100,12h" >> /etc/dnsmasq.conf'
sudo lxc-attach dns -- sh -c 'echo "dhcp-authoritative" >> /etc/dnsmasq.conf'
sudo lxc-attach dns -- sh -c 'echo "10.0.3.3 salt" >> /etc/hosts'

sudo lxc-attach dns -- systemctl restart dnsmasq

echo "Bootstrap Phase 3: Initialize the New Salt Master"
echo "########################################"

sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-M -A salt"

# For the dev session, Shutdown the saltmaster, add in appropriate
# mounts so we have all the salt files in the new saltmaster.
# in production, we'd manually pull from the git repo.
echo "Step 2. Setup Saltmaster for development environment"
sudo lxc-attach --name=salt -- mkdir /etc/salt/cloud.profiles.d
sudo lxc-attach --name=salt -- mkdir /etc/salt/cloud.providers.d
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

echo "Bootstrap Phase 4: Attach DNS server"
echo "########################################"
sudo lxc-attach dns -- apt-get install openssh-server
sudo lxc-attach dns -- sh -c 'echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config'
sudo lxc-attach dns -- systemctl restart sshd

# Make a keypair, put the key here '/tmp/mysshdnskey.pem'
# and put it in authorized keys for root on the dns.
ssh-keygen -N "" -f /tmp/mysshdnskey.pem -t rsa -b 4096
sudo lxc-attach dns -- mkdir -p /root/.ssh
sudo lxc-attach dns -- chmod 700 /root/.ssh
cat "/tmp/mysshdnskey.pem.pub" | sudo lxc-attach -n dns -- /bin/sh -c "cat > /root/.ssh/authorized_keys"
sudo lxc-attach dns -- chmod 644 /root/.ssh/authorized_keys

sudo salt-cloud -p salt-dns dnsaa



echo "Bootstrap Phase 5: Attach host"
echo "########################################"


# #echo "Step 1. Setup new Salt master"
# #sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-M -A salt"

# # Setup saltmaster:
# echo "Step 1. Setup new Salt master"
# set +e
# # Try this twice, it fails sometimes and I'm not sure why...
# sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-M -A salt"
# sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-M -A salt"
# set -e


# # Instantiate the cloud of the cloud:
# echo "Step 3. Produce cloud"
# sudo salt-cloud -y -m /vagrant/mapfile

# # Stop the old master, and connect vagrant.vm to the new one.
# sudo rm /etc/salt/pki/minion/minion_master.pub
# sudo rm /etc/salt/minion.d/99-master-address.conf
# sudo systemctl restart salt-minion
# sudo systemctl stop salt-master
# sudo systemctl disable salt-master

# # Accept all the keys
# sleep 90
# sudo lxc-attach --name=salt -- sudo salt-key -y -A

# echo "Bootstrap Phase 3: Orchestrating Cloud"
# echo "########################################"

# echo "Step 1. Setup monitoring infrastructure."
# salt="sudo lxc-attach --name=salt -- salt"
# $salt-run state.orchestrate _orchestrate.monitoring

