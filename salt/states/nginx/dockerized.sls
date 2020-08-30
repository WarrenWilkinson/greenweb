# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set dev = true %}

include:
  - docker
  - grafana.dockerized
  - phpBB.dockerized

{% if dev %}
  - cert.dev 
{% endif %}

{% set ssl_cert = '/opt/cert/development.crt' %}
{% set ssl_key = '/opt/cert/development.key' %}

/opt/nginx:
  file.directory:
    - user: root
    - group: root
    - mode: 755

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
{% for site in ['grafana', 'identity', 'hydra', 'phpbb'] %}
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
        - /opt/cert/:/opt/cert/:ro
        - /opt/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
        - /opt/nginx/sites-available/:/etc/nginx/sites-available/:ro
        - /opt/nginx/sites-enabled/:/etc/nginx/sites-enabled/:ro
        - /opt/phpbb/phpBB3:/opt/phpBB3:ro
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
        - production:
          - ipv4_address: {{ pillar['docker']['nginx'] }}
    - log_driver: syslog
    - log_opt:
        - tag: nginx
    - restart_policy: always
    - watch:
       - file: /opt/nginx/nginx.conf
       - file: /opt/nginx/sites-available/grafana.conf
       - file: /opt/nginx/sites-enabled/grafana.conf

