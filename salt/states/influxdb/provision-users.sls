# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - influxdb

influxdb_admin:
  influxdb_user.present:
    - name: {{ pillar['influxdb']['admin']['username'] }}
    - passwd: {{ pillar['influxdb']['admin']['password'] }}
    - admin: True
    - require:
      - service: influxdb
      - sls: influxdb.pip

/etc/influxdb/influxdb.conf:
  file.managed:
    - source: salt://influxdb/config/influxdb.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - influxdb_user: influxdb_admin

systemctl restart influxdb:
  cmd.run:
    - require:
        - file: /etc/influxdb/influxdb.conf
