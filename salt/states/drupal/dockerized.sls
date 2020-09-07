# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

# Add configuration file
{% set dbuser = pillar['drupal']['database']['username'] %}
{% set dbport = pillar['drupal']['database']['port'] %}
{% set dbpassword = pillar['drupal']['database']['password'] %}
{% set database = pillar['drupal']['database']['database'] %}
{% set dbhost = pillar['drupal']['database']['hostname'] %}

/opt/drupal:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/drupal/Dockerfile:
  file.managed:
    - source: salt://drupal/files/Dockerfile
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        dbhost: {{ dbhost }}
        dbport: {{ dbport }}
        dbname: {{ database }}
        dbuser: {{ dbuser }}
        dbpassword: {{ dbpassword }}
        base_url: https://drupal.greenweb.ca
    - require:
        - file: /opt/drupal

/opt/drupal/development.crt:
  file.managed:
    - source: salt://cert/files/development.crt
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/drupal

greenweb/drupal:
  docker_image.present:
    - build: /opt/drupal
    - tag: latest
    - watch:
      - file: /opt/drupal/Dockerfile
      - file: /opt/drupal/development.crt
    - require:
      - file: /opt/drupal/Dockerfile
      - file: /opt/drupal/development.crt
    - require_in:
      - docker_container: drupal

# Run it with the stuff mounted read-only inside.
drupal:
  docker_container.running:
    - name: drupal
    - image: greenweb/drupal:latest
    - extra_hosts: hydra.greenweb.ca:{{ pillar['docker']['static_ip'] }}
    - log_driver: syslog
#    - volumes: /var/www/html
    - restart_policy: always
    # - binds: /opt/drupal/drupal3:/var/www/html:rw
    - log_driver: syslog
    - log_opt:
        - tag: drupal
    - networks:
        - production
    - watch:
        - docker_image: greenweb/drupal
    - require:
        - docker_image: greenweb/drupal

# Mount that volume somewhere useful so we can volume
# mount it into nginx. Note I could also copy this
# and treat it as an installation, mounting it into
# drupal-8 for multiple sites.

{% set op = '{{' %}
{% set cl = '}}' %}

drupal_symlink:
  cmd.run:
    - name: 'docker inspect -f "{{ op }}range .Mounts{{ cl }}{{ op }}.Destination{{ cl }}:{{ op }}.Source{{ cl }}{{ op }}end{{ cl }}" drupal | grep /var/www/html: | cut -d: -f 2 | xargs -i{} ln -s {} /opt/drupal/webroot ;'
    - creates: /opt/drupal/webroot
    - require:
        - docker_container: drupal
