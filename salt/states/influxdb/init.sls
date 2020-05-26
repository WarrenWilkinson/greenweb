# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

base:
  pkgrepo.managed:
    - humanname: InfluxDB Upstream Repository
    - name: deb https://repos.influxdata.com/ubuntu xenial stable
    - dist: xenial
    - file: /etc/apt/sources.list.d/influxdb.list
    - gpgcheck: 1
    - key_url: https://repos.influxdata.com/influxdb.key
  pkg.latest:
    - name: influxdb
    - refresh: True

influxdb:        
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: influxdb
