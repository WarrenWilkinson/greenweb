# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

postgresql:
  pkg.installed:
    - name: postgresql
  service.running:
    - enable: true
    - watch:
      - pkg: postgresql
