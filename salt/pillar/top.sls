# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  'vagrant.vm':
    - lxc
    - nft
    - nginx.ip
  'influxdb':
    - telegraf_account
    - influxdb_account
  'nginx':
    - telegraf_account
  'logging':
    - telegraf_account
  'dns':
    - netplan.dns
    - nginx.ip
  'grafana':
    - grafana
    - telegraf_account
