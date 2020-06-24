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
      - file: /etc/postgresql/12/main/conf.d/10-custom.conf
      - file: /etc/postgresql/12/main/pg_hba.conf

/etc/postgresql/12/main/conf.d/10-custom.conf:
  file.managed:
    - source: salt://postgresql/files/10-custom.conf
    - user: root
    - group: root
    - mode: 644

# Create a user and database for keycloak.
{% set keycloak_user = pillar['keycloak']['database']['username'] %}
{% set keycloak_password = pillar['keycloak']['database']['password'] %}
{% set keycloak_database = pillar['keycloak']['database']['database'] %}

/etc/postgresql/12/main/pg_hba.conf:
  file.managed:
    - source: salt://postgresql/files/pg_hba.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        keycloak_user: {{ keycloak_user }}

keycloak_user:
  postgres_user.present:
    - name: {{ keycloak_user }}
    - password: {{ keycloak_password }}
    - createdb: false
    - createroles: false
    - encrypted: true
    - login: true
    - superuser: false
    - user: postgres

keycloak_database:
  postgres_database.present:
    - name: {{ keycloak_database }}
    - owner: {{ keycloak_user }}
    - user: postgres
