# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

influxdb_telegraf:
  influxdb_database.present:
    - name: "telegraf"
    - influxdb_user: {{ pillar['influxdb']['admin']['username'] }}
    - influxdb_password: {{ pillar['influxdb']['admin']['password'] }}

influxdb_telegraf_user:
  influxdb_user.present:
    - name: {{ pillar['telegraf']['influx_http']['username'] }}
    - passwd: {{ pillar['telegraf']['influx_http']['password'] }}
    - influxdb_user: {{ pillar['influxdb']['admin']['username'] }}
    - influxdb_password: {{ pillar['influxdb']['admin']['password'] }}
    - admin: False
    - grants:
        telegraf: all
    - require:
        - influxdb_database: influxdb_telegraf
