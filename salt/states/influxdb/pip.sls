# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

python-pip:
  pkg.installed

install_influxdb-python:
  pip.installed:
    - name: influxdb
    - require:
      - pkg: python-pip
