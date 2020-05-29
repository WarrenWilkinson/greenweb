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
and export the web services:

 - http://grafana.vagrant.vm:8080
