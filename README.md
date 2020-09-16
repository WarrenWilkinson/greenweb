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

    172.30.1.5             greenweb.ca forum.greenweb.ca mail.greenweb.ca identity.greenweb.ca grafana.greenweb.ca drupal.greenweb.ca

Once you're running the virtual machine, and have modified your hosts
file, you can visit the various external services:

  - http://grafana.greenweb.ca
  - http://forum.greenweb.ca
  - http://drupal.greenweb.ca

## Tests

In the development environment, a number of tests are installed in
/opt/test.  If you cd to this directory, you can run them with the
`runtest` command (no arguments necessary). Or this way (and then
look in dbg.log).

    runtest  --log_dialog --debug

To run a single test...

    runtest  --log_dialog test-successful-warren-send.exp
