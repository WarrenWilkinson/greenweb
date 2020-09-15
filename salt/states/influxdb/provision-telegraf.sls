# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

influxdb_telegraf:
  influxdb_database.present:
    - name: "telegraf"
    - influxdb_user: {{ pillar['influxdb']['admin']['username'] }}
    - influxdb_password: {{ pillar['influxdb']['admin']['password'] }}
