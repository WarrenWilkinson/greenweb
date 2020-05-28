# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

repo:
  pkgrepo.managed:
    - humanname: InfluxDB Upstream Repository
    - name: deb https://repos.influxdata.com/ubuntu bionic stable
    - dist: bionic
    - file: /etc/apt/sources.list.d/influxdb.list
    - gpgcheck: 1
    - key_url: https://repos.influxdata.com/influxdb.key