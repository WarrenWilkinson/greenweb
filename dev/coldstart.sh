#!/bin/bash
# Bootstrap a basic machine into a salt master

set -x
set -e

# Install some dependencies
sudo apt-get update
sudo apt-get install -y python-pygit2 lxd zfsutils-linux python-pip

# Install salt master software with salt-cloud support
cd /tmp
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -L -M -A 127.0.0.1 -i vagrant.vm

# Connect local client to local master
sleep 60
sudo salt-key -y -a vagrant.vm

# Finish setup, run twice because it seems to be necessary
set +e
sudo salt 'vagrant.vm' state.highstate
set -e
sudo salt 'vagrant.vm' state.highstate

# Bring up the cloud
# NOT THIS ONE. sudo salt-cloud -y -m /vagrant/mapfile
# And delete mapfile.
# sudo salt-call state.sls dev
