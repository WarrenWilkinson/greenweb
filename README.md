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

    172.30.1.5             greenweb.ca forum.greenweb.ca mail.greenweb.ca identity.greenweb.ca grafana.greenweb.ca

Now you should be able to visit the various external services:

  - http://grafana.greenweb.ca (TODO move this internal).


## Tests

In the development environment, a number of tests are installed in
/opt/test.  If you cd to this directory, you can run them with the
`runtest` command (no arguments necessary).
