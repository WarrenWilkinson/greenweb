# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  'vagrant.vm':
    - lxc
    - telegraf_account
    - nft
  'influxdb':
    - telegraf_account
    - influxdb_account
  'nginx':
    - telegraf_account
  'logging':
    - telegraf_account
