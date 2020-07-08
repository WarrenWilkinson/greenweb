# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

postfix:
  pkg.installed:
    - name: postfix
  service.running:
    - enable: true
    - watch:
      - pkg: postfix
      - file: /etc/postfix/main.cf

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/main.cf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        openvswitch_cidr: {{ pillar['openvswitch']['cidr'] }}
        external_ip: {{ pillar['external_ip'] }}

        
