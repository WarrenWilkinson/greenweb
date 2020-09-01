# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

# Setup the provisioning stuff

/opt/grafana:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/grafana/provisioning:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/grafana/provisioning/datasources:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/grafana/provisioning/dashboards:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/grafana/provisioning/json:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/grafana/provisioning/datasources/telegraf.yaml:
  file.managed:
    - source: salt://grafana/files/telegraf.yaml.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        telegraf_user: {{ pillar['telegraf']['influx_http']['username'] }}
        telegraf_password: {{ pillar['telegraf']['influx_http']['password'] }}

/opt/grafana/provisioning/dashboards/system.yaml:
  file.managed:
    - source: salt://grafana/files/system-dashboard.yaml.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja        
    - defaults:
        json: /etc/grafana/provisioning/json/system.json

/opt/grafana/provisioning/json/system.json:
  file.managed:
    - source: salt://grafana/files/system-dashboard.json
    - user: root
    - group: root
    - mode: 644


{% set dev = true %}
{% if dev %}

# docker run --name temp grafana/grafana:7.0.5 bash -c 'apk add python':
#   cmd.run:
#     - require_in:
#       - docker_image: grafana/grafana

/opt/grafana-dev:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/grafana-dev/development.crt:
  file.managed:
    - source: salt://cert/files/development.crt
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/grafana-dev

/opt/grafana-dev/Dockerfile:
  file.managed:
    - source: salt://grafana/files/Dockerfile
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/grafana-dev/development.crt
        - file: /opt/grafana-dev

grafana/grafana:
  docker_image.present:
    - build: /opt/grafana-dev
    - tag: dev
    - require_in:
      - docker_container: grafana
    - watch:
        - file: /opt/grafana-dev/development.crt
        - file: /opt/grafana-dev/Dockerfile

# grafana/grafana:
#   docker_image.present:
#     - tag: dev
#     - require_in:
#       - docker_container: grafana
#     - sls: cert.alpine-trust
#     - base: temp
#     - saltenv: base

{% set grafana_image = 'grafana/grafana:dev' %}
{% endif %}

# For now lock it down. Later, perhaps public facing so users can see
# their sites requirements.  Also needs SMTP integration, and might as
# well integrate with Postgresql and keycloak.
# TODO integrate some of these changes...
# /opt/grafana/grafana.ini:
#   file.managed:
#     - source: salt://grafana/files/grafana.ini.jinja
#     - user: root
#     - group: root
#     - mode: 644
#     - template: jinja
#     - defaults:
#         port: 3000
#         domain: grafana.greenweb.ca
#         root_url: http://grafana.greenweb.ca/ # because of proxy
#         admin_user: {{ pillar['grafana']['admin']['user'] }}
#         admin_password: {{ pillar['grafana']['admin']['password'] }}
#         secret_key: {{ pillar['grafana']['secret_key'] }}
#         disable_gravatar: true
#         cookie_secure: false
#         cookie_samesite: strict
#         allow_embedding: false
#         strict_transport_security: false # Insecure... but fix that later.
#         x_content_type_options: false
#         x_xss_protection: false
#         snapshots_external_enabled: false
#         allow_sign_up: false
#         log: syslog
#         rendering_timezone: America/Vancouver

# Run it!

grafana:
  docker_container.running:
    - name: grafana
    - image: {{ grafana_image }}
    - binds:
        - /opt/grafana/provisioning/:/etc/grafana/provisioning/:ro
    # No need, because it's on it's own network.
    # - port_bindings:
    #   - 3000:3000
    - environment:
      - GF_SERVER_DOMAIN: grafana.greenweb.ca
      - GF_SERVER_ROOT_URL: https://grafana.greenweb.ca/
      - GF_SECURITY_DISABLE_INITIAL_ADMIN_CREATION: True
      - GF_SECURITY_DISABLE_GRAVATAR: True
      - GF_USERS_ALLOW_SIGN_UP: False
      - GF_USERS_ALLOW_ORG_CREATE: False
      - GF_AUTH_DISABLE_LOGIN_FORM: True
      - GF_AUTH_GENERIC_OAUTH_ENABLED: True
      - GF_AUTH_GENERIC_OAUTH_CLIENT_ID: grafana
      - GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET: {{ pillar['hydra']['client_secret']['grafana'] }}
      - GF_AUTH_GENERIC_OAUTH_SCOPES: openid
      - GF_AUTH_GENERIC_OAUTH_AUTH_URL: https://hydra.greenweb.ca/oauth2/auth?login_challenge=grafana
      - GF_AUTH_GENERIC_OAUTH_TOKEN_URL: https://hydra.greenweb.ca/oauth2/token
#      - GF_AUTH_GENERIC_OAUTH_TOKEN_URL: https://nginx/hydra/oauth2/token
      - GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP: True
      - GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH: role
    - log_driver: syslog
    - log_opt:
        - tag: grafana
    - restart_policy: always
    - networks:
        - production
    - extra_hosts:
      - hydra.greenweb.ca:{{ pillar['docker']['nginx'] }}
    - watch:
        - file: /opt/grafana/provisioning/json/system.json
        - file: /opt/grafana/provisioning/dashboards/system.yaml
        - file: /opt/grafana/provisioning/datasources/telegraf.yaml

# grafana-server:
#   service.running:
#     - enable: True
#     - watch:
#       - pkg: grafana
#       - file: /etc/grafana/grafana.ini
#       - file: /etc/grafana/provisioning/datasources/telegraf.yaml
#       - file: /etc/grafana/provisioning/dashboards/system.yaml
#       - file: /var/lib/grafana/dashboards/system.json
