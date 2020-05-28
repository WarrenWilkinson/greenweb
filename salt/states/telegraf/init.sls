# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - influxdb.repo

telegraf:
  pkg.installed:
    - refresh: True
    - require:
      - sls: influxdb.repo
  service.running:
    - enable: True
    - watch:
      - pkg: telegraf
      - file: /etc/telegraf/telegraf.conf

/etc/telegraf/telegraf.conf:
  file.managed:
    - source: salt://telegraf/config/influxdb.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        username: {{ pillar['telegraf']['influx_http']['username'] }}
        password: {{ pillar['telegraf']['influx_http']['password'] }}

