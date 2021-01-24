# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

include:
  - docker
  - grafana.dockerized
  - phpbb.dockerized
  - drupal.demo
  - hydra.dockerized
  - werther.dockerized
{% if config.letsencrypt.use_pebble == true %}
  - cert.pebble
  - pebble.dockerized
{% endif %}

certbot:
  pkg.installed

/opt/nginx:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/nginx/conf:
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

{% set site_and_prefix = [('mail', none), ('grafana', 'grafana'), ('werther', 'identity'),
                          ('hydra', 'hydra'), ('phpbb', 'forum'), ('drupal', 'drupal')] %}

{% for (site, prefix) in site_and_prefix %}

/opt/nginx/conf/{{ site }}.conf:
  file.managed:
    - source: salt://nginx/config/nginx_{{ site }}.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
{% if prefix is not none %}
        ssl_cert: /etc/letsencrypt/live/{{ prefix }}.{{ domain}}/fullchain.pem
        ssl_key: /etc/letsencrypt/live/{{ prefix }}.{{ domain}}/privkey.pem
{% endif %}
        domain: {{ domain }}
    - require:
      - file: /opt/nginx/conf
{% endfor %}

nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:1.19.0
    - binds:
        - /etc/letsencrypt/:/etc/letsencrypt/:ro
        - /opt/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
        - /opt/nginx/conf/:/etc/nginx/user.conf.d/:ro
        - /opt/phpbb/phpBB3:/opt/phpBB3:ro
        - /opt/drupal/demo/web:/opt/drupal:ro
    - port_bindings:
      - 80:80
      - 443:443
    - networks:
        - production:
          - ipv4_address: {{ config.docker.nginx }}
    - log_driver: syslog
    - log_opt:
        - tag: nginx
    - restart_policy: always
    - require:
        - docker_container: grafana
        - docker_container: phpbb
        - docker_container: drupaldemo
        - docker_container: werther
        - docker_container: hydra
{% for (site, prefix) in site_and_prefix %}
        - file: /opt/nginx/conf/{{ site }}.conf
{% endfor %}
    - watch:
        - file: /opt/nginx/nginx.conf

# Once nginx is started, acme is proxied through and we can
# request certificates.
{% for (site, prefix) in site_and_prefix %}
{% if prefix is not none %}
{{ prefix }}.{{ domain }}:
  acme.cert:
{% if config.letsencrypt.use_pebble == true %}
    - server: https://pebble:14000/dir
{% endif %}
    - email: {{ config.letsencrypt.email }}
    - renew: 60
    - http_01_port: 8000
    - require:
      - docker_container: nginx
{% endif %}
{% endfor %}

# Now that we have keys, run this special script to restart nginx and uncomment
# that special line which will include all our other packages.
'sed -i "s/#SECONDPASS//" /opt/nginx/nginx.conf && docker restart nginx':
  cmd.run:
    - onlyif: grep -q "#SECONDPASS" /opt/nginx/nginx.conf
