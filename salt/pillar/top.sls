# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  '*':
    - telegraf.account
  'vmhost':
    - lxc
    - nft
    - nginx.ip
    - telegraf.memory
  'influxdb':
    - influxdb_account
  'dns':
    - netplan.dns
    - nginx.ip
  'grafana':
    - grafana
  'postgresql':
    - kubernetes.database
  'kubernetes':
    - kubernetes.database
