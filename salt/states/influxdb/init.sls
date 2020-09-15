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

