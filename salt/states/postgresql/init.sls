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

# Create a user and database for kubernetes.
{% set kbuser = pillar['kubernetes']['database']['username'] %}
{% set kbpass = pillar['kubernetes']['database']['password'] %}
{% set kbname = pillar['kubernetes']['database']['database'] %}

kubernetes_user:
  postgres_user.present:
    - name: {{ kbuser }}
    - password: {{ kbpass }}
    - createdb: false
    - createroles: false
    - encrypted: true
    - login: true
    - superuser: false
    - user: postgres

kubernetes_database:
  postgres_database.present:
    - name: {{ kbname }}
    - owner: {{ kbuser }}
    - user: postgres

# TODO Setup postgresql to listen to external connections.
