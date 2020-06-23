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

/opt/grafana/json:
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
        json: /opt/grafana/json/system.json

/opt/grafana/json/system.json:
  file.managed:
    - source: salt://grafana/files/system-dashboard.json
    - user: root
    - group: root
    - mode: 644

# Run it!

grafana:
  docker_container.running:
    - name: grafana
    - image: grafana/grafana:6.5.0
    - binds: /opt/grafana:/opt/grafana:ro
    - port_bindings:
      - 3000:3000
    - environment:
      - VAR1: value
    - log_driver: syslog
    - restart_policy: always
    - networks:
        - production

# # For now lock it down. Later, perhaps public facing so users can see
# # their sites requirements.  Also needs SMTP integration, and might as
# # well integrate with Postgresql and keycloak.
# /etc/grafana/grafana.ini:
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

# grafana-server:
#   service.running:
#     - enable: True
#     - watch:
#       - pkg: grafana
#       - file: /etc/grafana/grafana.ini
#       - file: /etc/grafana/provisioning/datasources/telegraf.yaml
#       - file: /etc/grafana/provisioning/dashboards/system.yaml
#       - file: /var/lib/grafana/dashboards/system.json
