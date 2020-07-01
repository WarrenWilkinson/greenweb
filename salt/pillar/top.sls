# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  '*':
    - telegraf.account
  'vmhost':
    - lxc
    - nft
    - docker.ip
    - telegraf.memory
    - telegraf.cpu
    - telegraf.disk
  'influxdb':
    - influxdb_account
  'dns':
    - netplan.dns
    - docker.ip
  'docker':
    - grafana
    - telegraf.memory
    - telegraf.disk
    - telegraf.docker
  'ldap':
    - ldap.rootpw
  'postgresql':
    - hydra.database
