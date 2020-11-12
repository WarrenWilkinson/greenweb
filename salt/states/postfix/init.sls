# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set org = config.internal_organization %}
{% set domain = config.internal_domain %}
{% set tl = config.internal_toplevel_domain %}

{% set dev = true %}

{% if dev %}
{% set ssl_cert = '/opt/cert/' + domain + '.crt' %}
{% set ssl_key = '/opt/cert/' + domain + '.key' %}
include:
  - cert.dev
{% endif %}

postfix:
  pkg.installed:
    - pkgs:
      - postfix
      - postfix-ldap
  service.running:
    - enable: true
    - watch:
      - pkg: postfix
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/master.cf

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/main.cf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        ssl_cert: {{ ssl_cert }}
        ssl_key: {{ ssl_key }}
        openvswitch_network: {{ pillar['openvswitch']['network'] }}
        external_ip: {{ pillar['external_ip'] }}

/etc/postfix/ldap:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: postfix

{% for file in ['virtual_mailbox_maps', 'virtual_alias_maps'] %}
/etc/postfix/ldap/{{ file }}.cf:
  file.managed:
    - source: salt://postfix/files/{{ file }}.cf.jinja
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - defaults:
        ldap_bind_dn: {{ pillar['postfix']['ldap']['dn'] }}
        ldap_bind_password: {{ pillar['postfix']['ldap']['password'] }}
        ldap_base: ou=email,dc={{ org }},dc={{ tl }}
        ldap_host: ldap.{{ domain }}
    - watch_in:
      - service: postfix
    - require:
      - file: /etc/postfix/ldap
{% endfor %}

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/master.cf
    - user: root
    - group: root
    - mode: 644
