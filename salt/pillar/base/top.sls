# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% from 'global_vars.jinja' import env with context %}
{% if env != '' %}
{{env}}:
  '*':
    - telegraf.account
  'vmhost':
    - openvswitch
    - lxc
    - nft
    - telegraf.memory
    - telegraf.cpu
    - telegraf.disk
  'influxdb':
    - influxdb_account
  'dns':
    - netplan.dns
  'docker':
    - grafana
    - telegraf.memory
    - telegraf.disk
    - telegraf.docker
    - hydra.database
    - hydra.secret
    - hydra.hydra_grafana_client_secret
    - hydra.hydra_phpbb_client_secret
    - hydra.hydra_drupal_client_secret
    - phpbb.database
    - phpbb.admin
    - drupal.database
    - drupal.admin
    - werther.ldap
  'ldap':
    - ldap.rootpw
    - dovecot.ldap
    - postfix.ldap
    - werther.ldap
  'postfix':
    - openvswitch
    - external_ip
    - dovecot.ldap
    - postfix.ldap
  'postgresql':
    - hydra.database
    - phpbb.database
    - drupal.database
{% endif %}
