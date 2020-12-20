# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

/usr/local/share/ca-certificates/pebble.crt:
  file.managed:
    - source: salt://cert/files/pebble.minica.pem
    - user: root
    - group: root
    - mode: 400

update-ca-certificates:
  cmd.run:
    - onchanges:
      - file: /usr/local/share/ca-certificates/pebble.crt
