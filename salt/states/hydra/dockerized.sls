# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

{% from 'hydra/dsn.sls' import dsn %}
{% set secret = pillar['hydra']['secret'] %}

hydra:
  docker_container.running:
    - name: hydra
    - image: oryd/hydra:v1.5.2
    # No need, because it's on it's own network.
    # - port_bindings:
    #   - 9000:4444
    #   - 9001:4445
    - environment:
      - SECRETS_SYSTEM: {{ secret }}
      - DSN: {{ dsn }}
      - URLS_SELF_ISSUER: https://localhost:9000/
      - URLS_CONSENT: http://identity.greenweb.ca/consent
      - URLS_LOGIN: http://identity.greenweb.ca/login
    - log_driver: syslog
    - restart_policy: always
    - networks:
        - production
