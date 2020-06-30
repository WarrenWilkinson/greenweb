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


{% for site in ['grafana', 'auth'] %}
/opt/nginx/sites-available/{{ site }}.conf:
  file.managed:
    - source: salt://nginx/config/nginx_{{ site }}.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /opt/nginx/sites-available

/opt/nginx/sites-enabled/{{ site }}.conf:
  file.managed:
    - source: salt://nginx/config/nginx_{{ site }}.conf
    - user: root
    - group: root
    - mode: 644
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

