# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

redis:
  pkg.installed:
    - name: redis
  service.running:
    - enable: true
    - watch:
      - pkg: redis
