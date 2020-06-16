# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

openjdk-11-jdk-headless:
  pkg.installed

keycloak-10.0.2.tar.gz:
  file.managed:
    - name: /opt/keycloak-10.0.2.tar.gz
    - source: https://downloads.jboss.org/keycloak/10.0.2/keycloak-10.0.2.tar.gz
    - source_hash: https://downloads.jboss.org/keycloak/10.0.2/keycloak-10.0.2.tar.gz.sha1
    - user: root
    - group: root
    - mode: 644

'tar -xzf keycloak-10.0.2.tar.gz':
  cmd.run:
    - creates: /opt/keycloak-10.0.2
    - cwd: /opt/

# TODO Create init script to launch keycloak.
