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

This will create a virtual machine (VM) and bootstrap it, installing
all the necessary software.  When it's done, it exists at 172.30.1.5. Modify
your /etc/hosts file to contain this line:

    172.30.1.5             vagrant.vm forum.vagrant.vm mail.vagrant.vm identity.vagrant.vm grafana.vagrant.vm

Now you should be able to visit the various external services:

  - http://grafana.vagrant.vm (TODO move this internal).
