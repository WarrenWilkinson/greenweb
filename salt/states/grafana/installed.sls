# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

grafana:
  pkgrepo.managed:
    - humanname: Grafana Upstream Repository
    - name: deb https://packages.grafana.com/oss/deb stable main
    - dist: stable
    - file: /etc/apt/sources.list.d/grafana.list
    - gpgcheck: 1
    - key_url: https://packages.grafana.com/gpg.key
  pkg.installed:
    - name: grafana
    - refresh: True

/etc/grafana/provisioning/datasources/telegraf.yaml:
  file.managed:
    - source: salt://grafana/files/telegraf.yaml.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        telegraf_user: {{ pillar['telegraf']['influx_http']['username'] }}
        telegraf_password: {{ pillar['telegraf']['influx_http']['password'] }}

/var/lib/grafana/dashboards:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/etc/grafana/provisioning/dashboards/system.yaml:
  file.managed:
    - source: salt://grafana/files/system-dashboard.yaml.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        json: /var/lib/grafana/dashboards/system.json

/var/lib/grafana/dashboards/system.json:
  file.managed:
    - source: salt://grafana/files/system-dashboard.json
    - user: root
    - group: root
    - mode: 644

# For now lock it down. Later, perhaps public facing so users can see
# their sites requirements.  Also needs SMTP integration, and might as
# well integrate with Postgresql and keycloak.
/etc/grafana/grafana.ini:
  file.managed:
    - source: salt://grafana/files/grafana.ini.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        port: 3000
        domain: grafana.{{ domain }}
        root_url: http://grafana.{{ domain }}/ # because of proxy
        admin_user: {{ pillar['grafana']['admin']['user'] }}
        admin_password: {{ pillar['grafana']['admin']['password'] }}
        secret_key: {{ pillar['grafana']['secret_key'] }}
        disable_gravatar: true
        cookie_secure: false
        cookie_samesite: strict
        allow_embedding: false
        strict_transport_security: false # Insecure... but fix that later.
        x_content_type_options: false
        x_xss_protection: false
        snapshots_external_enabled: false
        allow_sign_up: false
        log: syslog
        rendering_timezone: America/Vancouver

grafana-server:
  service.running:
    - enable: True
    - watch:
      - pkg: grafana
      - file: /etc/grafana/grafana.ini
      - file: /etc/grafana/provisioning/datasources/telegraf.yaml
      - file: /etc/grafana/provisioning/dashboards/system.yaml
      - file: /var/lib/grafana/dashboards/system.json
