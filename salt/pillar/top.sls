# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  'vagrant.vm':
    - lxc
    - telegraf_account
  'influxdb':
    - telegraf_account
    - influxdb_account
  'nginx':
    - telegraf_account
  'logging':
    - telegraf_account
