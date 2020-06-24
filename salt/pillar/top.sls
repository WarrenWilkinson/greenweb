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
    - telegraf.disk
    - telegraf.docker
