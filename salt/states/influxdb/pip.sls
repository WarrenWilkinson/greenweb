# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

python3-pip:
  pkg.installed

install_influxdb-python:
  pip.installed:
    - name: influxdb
    - require:
      - pkg: python3-pip
