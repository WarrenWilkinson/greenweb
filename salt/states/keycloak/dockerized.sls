# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set keycloak_user = pillar['keycloak']['database']['username'] %}
{% set keycloak_password = pillar['keycloak']['database']['password'] %}
{% set keycloak_database = pillar['keycloak']['database']['database'] %}
{% set keycloak_hostname = pillar['keycloak']['database']['hostname'] %}
{% set keycloak_port = pillar['keycloak']['database']['port'] %}

include:
  - docker

keycloak:
  docker_container.running:
    - name: keycloak
    - image: jboss/keycloak:10.0.2
    - port_bindings:
      - 8080:8080
    - environment:
      - KEYCLOAK_USER: {{ pillar['keycloak']['admin']['username'] }}
      - KEYCLOAK_PASSWORD: {{ pillar['keycloak']['admin']['password'] }}
      - DB_VENDOR: postgres
      - DB_ADDR: {{ keycloak_hostname }}
      - DB_PORT: {{ keycloak_port }}
      - DB_DATABASE: {{ keycloak_database }}
      - DB_USER: {{ keycloak_user }}
      - DB_PASSWORK: {{ keycloak_password }}
      - PROXY_ADDRESS_FORWARDING: true
      # - KEYCLOAK_IMPART: /tmp/keycloak-realm.json
    - log_driver: syslog
    - restart_policy: always
    - networks:
        - production

# openjdk-11-jdk-headless:
#   pkg.installed

# keycloak-10.0.2.tar.gz:
#   file.managed:
#     - name: /opt/keycloak-10.0.2.tar.gz
#     - source: https://downloads.jboss.org/keycloak/10.0.2/keycloak-10.0.2.tar.gz
#     - source_hash: https://downloads.jboss.org/keycloak/10.0.2/keycloak-10.0.2.tar.gz.sha1
#     - user: root
#     - group: root
#     - mode: 644

# 'tar -xzf keycloak-10.0.2.tar.gz':
#   cmd.run:
#     - creates: /opt/keycloak-10.0.2
#     - cwd: /opt/

# # TODO Create init script to launch keycloak.
