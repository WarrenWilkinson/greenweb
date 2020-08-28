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
    - postfix.ip
    - telegraf.memory
    - telegraf.cpu
    - telegraf.disk
  'influxdb':
    - influxdb_account
  'dns':
    - netplan.dns
    - docker.ip
    - postfix.ip
  'docker':
    - grafana
    - telegraf.memory
    - telegraf.disk
    - telegraf.docker
    - hydra.database
    - hydra.secret
    - docker.ip
    - hydra.hydra_grafana_client_secret
    - hydra.hydra_phpbb_client_secret
    - phpbb.database
    - phpbb.admin
  'ldap':
    - ldap.rootpw
    - dovecot.ldap
    - postfix.ldap
  'postfix':
    - openvswitch
    - external_ip
    - dovecot.ldap
    - postfix.ldap
  'postgresql':
    - hydra.database
    - phpbb.database
