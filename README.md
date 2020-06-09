# Green Web Infrastructure

This infrastructure project is intended to help groups in the
Tri-cities, be online in an effective way.

Video Pitch: https://www.youtube.com/watch?v=G41NQj-6Sv0

This repository contains deployment scripts for software
side of this project.

## Getting Started

Development starts in the 'dev' environment, which is a local vagrant
box. Start it up:

    cd dev
    vagrant up

This will create a virtual machine (VM) on which salt will
self-install and begin bootstrapping.  Salt will instruct the VM to
create additional LXC instances (LXC is a light weight linux form of
virtualization).

One of these LXC instances will become a new salt master, and all will join
onto it. The next stage of bootstrapping provisions all of these machines
and export the web services.  Bind your local ports 80 and 443 to the virtual machine (any
password is probably 'vagrant'):

    sudo ssh -p 2222 -gNfL 80:localhost:80 vagrant@localhost -i ~/.vagrant.d/insecure_private_key
    sudo ssh -p 2222 -gNfL 443:localhost:443 vagrant@localhost -i ~/.vagrant.d/insecure_private_key

And add this line to your /etc/hosts:

    127.0.0.1	localhost vagrant.vm grafana.vagrant.vm mail.vagrant.vm identity.vagrant.vm

You should now be able to check out the various services:

  - http://grafana.vagrant.vm

TODO, setup a VPN or something and hide grafana behind that.
