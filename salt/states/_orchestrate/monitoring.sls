# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

# Ensure nginx is installed on Nginx.
# Ensure influxdb in installed
# Ensure grafana is installed.
# Combine all three.

# This is needed to be run
# so that saltstacks management of
# influxdb databases and users works
# in the next step.
influx_pip:
  salt.state:
    - tgt: 'influxdb'
    - sls:
      - influxdb.pip

prep_servers:
  salt.state:
    - tgt: 'nginx,influxdb,grafana,logging,vagrant.vm'
    - tgt_type: list
    - highstate: True

nat:
  salt.state:
    - tgt: 'vagrant.vm'
    - sls:
      - nft
