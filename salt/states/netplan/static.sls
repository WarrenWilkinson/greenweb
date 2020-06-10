# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set outputfile = pillar['netplan']['file'] %}

{{ outputfile }}:
  file.managed:
    - source: salt://netplan/files/static-config.yaml.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        interface: {{ pillar['netplan']['interface'] }}
        gateway4: {{ pillar['netplan']['gateway4'] }}
        ip4: {{ pillar['netplan']['ip4'] }}
        search: {{ pillar['netplan']['nameservers']['search'] }}
        addresses: {{ pillar['netplan']['nameservers']['addresses'] }}
