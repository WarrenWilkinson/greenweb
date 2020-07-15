# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set dev = true %}

{% if dev %}
{% set ssl_cert = '/opt/cert/development.crt' %}
{% set ssl_key = '/opt/cert/development.key' %}
include:
  - cert.dev
{% endif %}

postfix:
  pkg.installed:
    - name: postfix
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
        openvswitch_cidr: {{ pillar['openvswitch']['cidr'] }}
        external_ip: {{ pillar['external_ip'] }}

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/master.cf
    - user: root
    - group: root
    - mode: 644
