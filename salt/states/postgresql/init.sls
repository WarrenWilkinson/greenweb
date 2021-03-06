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

# Create a user and database for hydra and phpbb
{% set hydra_user = pillar['hydra']['database']['username'] %}
{% set hydra_password = pillar['hydra']['database']['password'] %}
{% set hydra_database = pillar['hydra']['database']['database'] %}

{% set phpbb_user = pillar['phpbb']['database']['username'] %}
{% set phpbb_password = pillar['phpbb']['database']['password'] %}
{% set phpbb_database = pillar['phpbb']['database']['database'] %}

{% set drupal_user = pillar['drupal']['database']['username'] %}
{% set drupal_password = pillar['drupal']['database']['password'] %}
{% set drupal_database = pillar['drupal']['database']['database'] %}

/etc/postgresql/12/main/pg_hba.conf:
  file.managed:
    - source: salt://postgresql/files/pg_hba.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        hydra_user: {{ hydra_user }}
        phpbb_user: {{ phpbb_user }}
        drupal_user: {{ drupal_user }}

hydra_user:
  postgres_user.present:
    - name: {{ hydra_user }}
    - password: {{ hydra_password }}
    - createdb: false
    - createroles: false
    - encrypted: true
    - login: true
    - superuser: false
    - user: postgres

hydra_database:
  postgres_database.present:
    - name: {{ hydra_database }}
    - owner: {{ hydra_user }}
    - user: postgres

phpbb_user:
  postgres_user.present:
    - name: {{ phpbb_user }}
    - password: {{ phpbb_password }}
    - createdb: false
    - createroles: false
    - encrypted: true
    - login: true
    - superuser: false
    - user: postgres

phpbb_database:
  postgres_database.present:
    - name: {{ phpbb_database }}
    - owner: {{ phpbb_user }}
    - user: postgres

drupal_user:
  postgres_user.present:
    - name: {{ drupal_user }}
    - password: {{ drupal_password }}
    - createdb: false
    - createroles: false
    - encrypted: true
    - login: true
    - superuser: false
    - user: postgres

drupal_database:
  postgres_database.present:
    - name: {{ drupal_database }}
    - owner: {{ drupal_user }}
    - user: postgres
