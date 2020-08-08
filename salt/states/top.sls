# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---


base:
    'netplan:static:true':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
    'salt':
      - libvirt
    'vmhost':
      - zpool
      - lxc
      - nft
      - telegraf
      - libvirt
      - libvirt.focal-img
      - openldap.utils
    'ldap':
      - m4
      - openldap
    'influxdb':
      - influxdb
    'dns':
      - dnsmasq
    'docker':
      - docker
      - telegraf
      - grafana.dockerized
      - nginx.dockerized
      - identity.dockerized
      - hydra.dockerized
    'postfix':
      - dovecot
      - postfix
    'postgresql':
      - postgresql
    'redis':
      - redis
