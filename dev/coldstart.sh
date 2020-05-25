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
sudo salt 'vagrant.vm' lxc.init saltmaster profile=standard_xenial network_profile=standard_net bootstrap_args="-M -A saltmaster"

# Instantiate the cloud of the cloud:
sudo salt-cloud -y -m /vagrant/mapfile

# Accept all the keys
sleep 90
sudo lxc-attach --name=saltmaster -- sudo salt-key -y -A

# TODO Join the host computer to the salt master.

echo "Bootstrap Phase 3: Orchestrating Cloud"
echo "########################################"
