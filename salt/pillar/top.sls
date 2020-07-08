# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  '*':
    - telegraf.account
  'vmhost':
    - openvswitch
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
    - hydra.database
    - hydra.secret
    - docker.ip
    - hydra.hydra_grafana_client_secret
  'ldap':
    - ldap.rootpw
  'postfix':
    - openvswitch
    - external_ip
  'postgresql':
    - hydra.database
