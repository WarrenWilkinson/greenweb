# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set org = config.internal_organization %}
{% set domain = config.internal_domain %}
{% set tl = config.internal_toplevel_domain %}

include:
  - docker

{% set dev = true %}
{% if dev %}
{{ org }}/werther:
  docker_image.present:
    - build: /opt/werther
    - tag: latest
    - require_in:
      - docker_container: werther
{% endif %}

werther:
  docker_container.running:
    - name: werther
{% if dev %}
    - image: {{ org }}/werther:latest
{% else %}
    - image: icoreru/werther:v1.1.1
{% endif %}
    - environment:
      - MOCK_TLS_TERMINATION: True # OR, route the admin port through nginx and add the host.
      - WERTHER_IDENTP_HYDRA_URL: http://hydra:4445
      - WERTHER_LDAP_ENDPOINTS: ldap.{{ domain }}:389
      - WERTHER_LDAP_BINDDN: {{ config.werther.bind_dn }}
      - WERTHER_LDAP_BINDPW: {{ pillar['werther']['ldap']['password'] }}
      - WERTHER_LDAP_BASEDN: ou=people,dc={{ org }},dc={{ tl }}
      - WERTHER_LDAP_ROLE_BASEDN: ou=grants,dc={{ org }},dc={{ tl }}
      - WERTHER_LDAP_ATTR_CLAIMS: givenName:given_name,displayName:name,cn:nickname,sn:family_name,mail:email,uid:preferred_username,employeeNumber:zoneinfo,preferredLanguage:locale
      - WERTHER_LDAP_ROLE_CLAIM: https://{{ domain }}/claims/roles
      - WERTHER_IDENTP_CLAIM_SCOPES: given_name:profile,name:profile,nickname:profile,family_name:profile,preferred_username:profile,zoneinfo:profile,locale:profile,email:email,https%3A%2F%2F{{ domain }}%2Fclaims%2Froles:roles
    - log_driver: syslog
    - log_opt:
        - tag: werther
    - restart_policy: always
    - networks:
        - production
