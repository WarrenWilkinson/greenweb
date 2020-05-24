#!/bin/sh
# This script is intended to bootstrap LXD instances.  It simply goes
# in and enables an ssh server that allows root access and password
# based login. The password for root is changed to 'password'.
#
# It is expected that once salt is configured, the highstate will
# remove or secure the openssh server and the root password.

set -x
set -e

sudo apt-get update
sudo apt-get install -y openssh-server
sed -i -e 's/^#* *PermitRootLogin .*$/PermitRootLogin yes/g' -e 's/^#* *PasswordAuthentication .*$/PasswordAuthentication yes/g' '/etc/ssh/sshd_config' > /tmp/new_sshd_config
sudo mv /tmp/new_sshd_config /etc/ssh/sshd_config
sudo usermod --password '$1$Q3J0TuD5$zuS/qAcS139eyXrmAcWyu1' root
sudo systemctl restart sshd
