# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

/opt/cert:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/cert/development.key:
  file.managed:
    - source: salt://cert/files/development.key
    - user: root
    - group: root
    - mode: 400

/opt/cert/development.crt:
  file.managed:
    - source: salt://cert/files/development.crt
    - user: root
    - group: root
    - mode: 400
