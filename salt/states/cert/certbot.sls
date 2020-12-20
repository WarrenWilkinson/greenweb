# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

certbot:
  pkg.installed:
    - pkgs:
      - certbot
      - python3-certbot-nginx

postfix.{{ domain }}:
  acme.cert:
{% if config.letsencrypt.use_pebble == true %}
    - server: https://pebble:14000/dir
{% endif %}
    # - aliases:
    #   - gitlab.example.com
    - email: {{ config.letsencrypt.email }}
    - renew: 60
#    - fire_event: acme/dev.example.com
    # - onchanges_in:
    #   - cmd: reload-gitlab
