# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

{% set dev = true %}
{% if dev %}
greenweb/identity:
  docker_image.present:
    - build: /opt/greenwebauth
    - tag: latest
    - require_in:
      - docker_container: identity
{% endif %}

identity:
  docker_container.running:
    - name: identity
    - image: greenweb/identity:latest
    # - binds:
    #     - /opt/auth/provisioning/:/etc/auth/provisioning/:ro
    # No need, because it's on it's own network
    # - port_bindings:
    #   - 3333:3000
    - environment:
      - VAR1: value
    - log_driver: syslog
    - restart_policy: always
    - networks:
        - production
