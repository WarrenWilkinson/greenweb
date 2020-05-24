#!/bin/bash
# Bootstrap a basic machine into a salt master

set -x
set -e

echo "Installing a few dependencies..."
# Install some dependencies
sudo apt-get update
sudo apt-get install -y python-pygit2 lxd zfsutils-linux python-pip

echo "Bootstrap Phase 0: Installing salt"
echo "########################################"
# Install salt master software with salt-cloud support
cd /tmp
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -L -M -A 127.0.0.1 -i vagrant.vm

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
# Bring up the cloud
# NOT THIS ONE. sudo salt-cloud -y -m /vagrant/mapfile
# And delete mapfile.
# sudo salt-call state.sls dev
sudo salt-cloud -y -m /vagrant/saltify-map

echo "Bootstrap Phase 3: Orchestrating Cloud"
echo "########################################"
