# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

/opt/cert:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/cert/{{ domain }}.key:
  file.managed:
    - source: salt://cert/files/{{ domain }}.key
    - user: root
    - group: root
    - mode: 400

/opt/cert/{{ domain }}.crt:
  file.managed:
    - source: salt://cert/files/{{ domain }}.crt
    - user: root
    - group: root
    - mode: 400
