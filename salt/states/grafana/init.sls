# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

grafana:
  pkgrepo.managed:
    - humanname: Grafana Upstream Repository
    - name: deb https://packages.grafana.com/oss/deb stable main
    - dist: stable
    - file: /etc/apt/sources.list.d/grafana.list
    - gpgcheck: 1
    - key_url: https://packages.grafana.com/gpg.key
  pkg.latest:
    - name: grafana
    - refresh: True

grafana-server:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: grafana
