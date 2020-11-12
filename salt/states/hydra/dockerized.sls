# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

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
    #   - 4444:4444 # The public API (which nginx handles)
    #   - 4445:4445 # The admin API (not exposed)
    - command: "serve all"
    - environment:
      - SECRETS_SYSTEM: {{ secret }}
      - DSN: {{ dsn }}
      - URLS_SELF_ISSUER: https://hydra.{{ domain }}/
      - URLS_CONSENT: https://identity.{{ domain }}/auth/consent
      - URLS_LOGIN: https://identity.{{ domain }}/auth/login
      - URLS_LOGOUT: https://identity.{{ domain }}/auth/logout
      - WEBFINGER_OIDC_DISCOVERY_SUPPORTED_SCOPES: profile,email,roles
      - WEBFINGER_OIDC_DISCOVERY_SUPPORTED_CLAIMS: name,given_name,nickname,family_name,preferred_username,zoneinfo,locale,email,https://{{ domain }}/claims/roles
      - SERVE_TLS_ALLOW_TERMINATION_FROM: {{ config.docker.subnet }}
      - OAUTH2_EXPOSE_INTERNAL_ERRORS: True
    - log_driver: syslog
    - log_opt:
        - tag: hydra
    - restart_policy: always
    - networks:
        - production
