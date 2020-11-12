#!/bin/bash
# Bootstrap a basic machine into a salt master

MODE=${1:-base}
echo "Bootstrapping ${MODE}"

set -e
set -x

set +x
sudo sed -i "s/{% set env = '.*' %}/{% set env = '${MODE}' %}/" /srv/pillar/base/global_vars.jinja
sudo sed -i "s/^\\(.*\\)pillarenv:.*$/\\1pillarenv: ${MODE}/" /etc/salt/cloud.profiles.d/lxc-focal.conf
sudo sed -i "s/^\\(.*\\)pillarenv:.*$/\\1pillarenv: ${MODE}/" /etc/salt/cloud.profiles.d/kvm-focal.conf
sudo mkdir -p /etc/salt/gpgkeys
sudo chmod 700 /etc/salt/gpgkeys
if [ $MODE != "base" ]; then
    echo "Importing private key /vagrant/${MODE}_privkey.gpg"
    sudo gpg --homedir /etc/salt/gpgkeys --import "/vagrant/${MODE}_privkey.gpg"
    echo "Importing public key /vagrant/${MODE}_pubkey.gpg"
    sudo gpg --homedir /etc/salt/gpgkeys --import "/vagrant/${MODE}_pubkey.gpg"
fi

echo "Checking that configuration.yaml exists..."
CONFIG_FILE="/srv/salt/configuration.yaml"
if [ ! -f "${CONFIG_FILE}" ]; then
   if [ ! -f "${CONFIG_FILE}.template" ]; then
       echo "${CONFIG_FILE} does not exist, and nor does ${CONFIG_FILE}.template to create it from."
      exit 1
   else
       echo "Creating ${CONFIG_FILE} based on ${CONFIG_FILE}.template."
       sudo cp "${CONFIG_FILE}.template" "${CONFIG_FILE}"
   fi
fi
set -x

# echo "Installing a few dependencies..."
# Install some dependencies
# sudo apt-get update
# sudo apt-get install -y python-pygit2 lxc zfsutils-linux python-pip

echo "Bootstrap Phase 0: Installing salt"
echo "########################################"
# Install salt master software with salt-cloud support
cd /tmp
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sudo sh bootstrap-salt.sh -L -M -A 127.0.0.1 -i vmhost -x python3 -j "{ \"pillarenv\": \"${MODE}\" }"

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

set +x
INTERNAL_DOMAIN=`sudo salt-call slsutil.renderer salt://configuration.yaml --out key | awk '/internal_domain/ { print $2 }'`
echo "Detected internal_domain is \"${INTERNAL_DOMAIN}\"."
KEY_FILE="/vagrant/${INTERNAL_DOMAIN}.key"
CERT_FILE="/vagrant/${INTERNAL_DOMAIN}.crt"
KEY_DEST="/srv/salt/cert/files/${INTERNAL_DOMAIN}.key"
CERT_DEST="/srv/salt/cert/files/${INTERNAL_DOMAIN}.crt"

echo "Checking \"${KEY_FILE}\" exists..."
if [ ! -f "${KEY_FILE}" ]; then
    echo "${KEY_FILE} does not exist."
    exit 1
else
    echo "Copying ${KEY_FILE} to ${KEY_DEST}."
    sudo cp "${KEY_FILE}" "${KEY_DEST}"
fi

echo "Checking \"${CERT_FILE}\" exists..."
if [ ! -f "${CERT_FILE}" ]; then
    echo "${CERT_FILE} does not exist."
    exit 1
else
    echo "Copying ${CERT_FILE} to ${CERT_DEST}."
    sudo cp "${CERT_FILE}" "${CERT_DEST}"
fi

set -x

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
sudo lxc-attach bootdns -- sh -c "echo "domain=${INTERNAL_DOMAIN}" >> /etc/dnsmasq.conf"
sudo lxc-attach bootdns -- sh -c "echo "local=/${INTERNAL_DOMAIN}/" >> /etc/dnsmasq.conf"
sudo lxc-attach bootdns -- sh -c 'echo "expand-hosts" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "dhcp-range=10.0.3.70,10.0.3.100,12h" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "dhcp-authoritative" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- sh -c 'echo "dhcp-option=option:router,10.0.3.1" >> /etc/dnsmasq.conf'
sudo lxc-attach bootdns -- systemctl restart dnsmasq

echo "Bootstrap Phase 3: Initialize the New Salt Master"
echo "########################################"

sudo salt 'vmhost' lxc.init salt profile=standard_focal network_profile=standard_net config="{ \"pillarenv\": \"${MODE}\"}" bootstrap_args="-L -M -A salt -x python3"

# Create a space to mount libvirt into it.
sudo lxc-attach --name=salt -- mkdir /opt/libvirt

# For the dev session, Shutdown the saltmaster, add in appropriate
# mounts so we have all the salt files in the new saltmaster.
# in production, we'd manually pull from the git repo.
# echo "Step 2. Setup Saltmaster for development environment"
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/cloud.profiles.d
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/cloud.providers.d
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/master.d
sudo lxc-attach --name=salt -- mkdir -p /etc/salt/gpgkeys
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
lxc.mount.entry = /etc/salt/gpgkeys etc/salt/gpgkeys none ro,bind 0 0
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

echo "Bootstrap Phase 5: Set up Logging"
echo "########################################"

sudo mkdir /var/log/remote
sudo chown syslog:syslog /var/log/remote

$salt-cloud -p lxc-focal logging
sudo lxc-attach --name=logging -- mkdir -p /var/log/remote
sudo lxc-stop logging
cat <<EOF | sudo tee -a /var/lib/lxc/logging/config

# Logging Mounts
lxc.mount.entry = /var/log/remote var/log/remote none rw,bind 0 0
EOF

sudo lxc-start logging
sleep 10
set +e
$salt 'logging' state.highstate
set -e
$salt 'logging' state.highstate

echo "Bootstrap Phase 6: Orchestrating Cloud"
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
$salt 'influxdb' state.highstate
$salt 'influxdb' state.sls influxdb.provision-users
sleep 5
$salt 'influxdb' state.sls influxdb.provision-telegraf

$salt 'docker' state.sls hydra.migrate
$salt '*' state.highstate
$salt 'docker' state.sls hydra.provision
$salt 'docker' state.sls phpbb.provision

#$salt-run state.orchestrate _orchestrate.monitoring
