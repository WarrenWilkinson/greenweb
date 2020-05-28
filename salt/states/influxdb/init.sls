# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - influxdb.repo
  - influxdb.pip

influxdb:
  pkg.installed:
    - refresh: True
    - require:
      - sls: influxdb.repo
  service.running:
    - enable: True
    - watch:
      - pkg: influxdb
      - file: /etc/influxdb/influxdb.conf

influxdb_telegraf_db:
  influxdb_database.present:
    - name: "telegraf"
    - require:
      - service: influxdb
      - sls: influxdb.pip

influxdb_telegraf_user:
  influxdb_user.present:
    - name: {{ pillar['telegraf']['influx_http']['username'] }}
    - passwd: {{ pillar['telegraf']['influx_http']['password'] }}
    - admin: False
    - require:
      - service: influxdb
      - sls: influxdb.pip

influxdb_telegraf_retention:
  influxdb_retention_policy.present:
    - name: "telegraf retention"
    - database: "telegraf"
    - duration: "21d"
    - require:
      - service: influxdb
      - sls: influxdb.pip

/etc/influxdb/influxdb.conf:
  file.managed:
    - source: salt://influxdb/config/influxdb.conf
    - user: root
    - group: root
    - mode: 644
