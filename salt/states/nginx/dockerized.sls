# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker
  - grafana.dockerized

/opt/nginx:
  file.directory:
    - user: root
    - group: root
    - mode: 755

{% set dev = true %}
{% set ssl_cert = '/opt/cert/development.crt' %}
{% set ssl_key = '/opt/cert/development.key' %}
{% if dev %}
/opt/nginx/cert:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/nginx/cert/development.key:
  file.managed:
    - source: salt://nginx/files/development.key
    - user: root
    - group: root
    - mode: 444

/opt/nginx/cert/development.crt:
  file.managed:
    - source: salt://nginx/files/development.crt
    - user: root
    - group: root
    - mode: 444
{% endif %}

/opt/nginx/sites-available:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/nginx

/opt/nginx/sites-enabled:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/nginx

/opt/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/config/nginx.conf
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/nginx

# NOTE: In production, I don't need to normally expose
# hydra.
{% for site in ['grafana', 'identity', 'hydra'] %}
/opt/nginx/sites-available/{{ site }}.conf:
  file.managed:
    - source: salt://nginx/config/nginx_{{ site }}.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        ssl_cert: {{ ssl_cert }}
        ssl_key: {{ ssl_key }}
    - require:
      - file: /opt/nginx/sites-available

/opt/nginx/sites-enabled/{{ site }}.conf:
  file.managed:
    - source: salt://nginx/config/nginx_{{ site }}.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        ssl_cert: {{ ssl_cert }}
        ssl_key: {{ ssl_key }}
    - require:
      - file: /opt/nginx/sites-enabled
    - watch_in:
      - docker_container: nginx
{% endfor %}

nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:1.19.0
    - binds:
        - /opt/nginx/cert/:/opt/cert/:ro
        - /opt/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
        - /opt/nginx/sites-available/:/etc/nginx/sites-available/:ro
        - /opt/nginx/sites-enabled/:/etc/nginx/sites-enabled/:ro
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
        - production
    - log_driver: syslog
    - restart_policy: always
    - watch:
       - file: /opt/nginx/nginx.conf
       - file: /opt/nginx/sites-available/grafana.conf
       - file: /opt/nginx/sites-enabled/grafana.conf

