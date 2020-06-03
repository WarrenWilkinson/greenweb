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

echo "Bootstrap Phase 2: Provisioning Cloud"
echo "########################################"

# Setup saltmaster:
echo "Step 1. Setup new Salt master"
sleep 30
set +e
# Try this twice, it fails sometimes and I'm not sure why...
sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-M -A salt"
sudo salt 'vagrant.vm' lxc.init salt profile=standard_bionic network_profile=standard_net bootstrap_args="-M -A salt"
set -e

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

# Instantiate the cloud of the cloud:
echo "Step 3. Produce cloud"
sudo salt-cloud -y -m /vagrant/mapfile

# Stop the old master, and connect vagrant.vm to the new one.
sudo rm /etc/salt/pki/minion/minion_master.pub
sudo rm /etc/salt/minion.d/99-master-address.conf
sudo systemctl restart salt-minion
sudo systemctl stop salt-master
sudo systemctl disable salt-master

# Accept all the keys
sleep 90
sudo lxc-attach --name=salt -- sudo salt-key -y -A

echo "Bootstrap Phase 3: Orchestrating Cloud"
echo "########################################"

echo "Step 1. Setup monitoring infrastructure."
salt="sudo lxc-attach --name=salt -- salt"
$salt-run state.orchestrate _orchestrate.monitoring

