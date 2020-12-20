# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

base:
    'netplan:static:true':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
      - logrotate
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
      - fail2ban
      - dejagnu
      - postfix.null
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
      - werther.dockerized
      - hydra.dockerized
      - phpbb.dockerized
      - postgresql.client
{% if config.letsencrypt.use_pebble == true %}
      - pebble.dockerized
{% endif %}
    'postfix':
      - dovecot
      - postfix
    'postgresql':
      - postgresql
    'redis':
      - redis
