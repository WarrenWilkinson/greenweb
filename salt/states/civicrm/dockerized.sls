# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

# Add configuration file
{% set dbuser = pillar['civicrm']['database']['username'] %}
{% set dbport = pillar['civicrm']['database']['port'] %}
{% set dbpassword = pillar['civicrm']['database']['password'] %}
{% set database = pillar['civicrm']['database']['database'] %}
{% set dbhost = pillar['civicrm']['database']['hostname'] %}

/opt/civicrm:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/civicrm/Dockerfile:
  file.managed:
    - source: salt://civicrm/files/Dockerfile
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
        base_url: https://civicrm.greenweb.ca
    - require:
        - file: /opt/civicrm

/opt/civicrm/development.crt:
  file.managed:
    - source: salt://cert/files/development.crt
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/civicrm

greenweb/civicrm:
  docker_image.present:
    - build: /opt/civicrm
    - tag: latest
    - watch:
      - file: /opt/civicrm/Dockerfile
      - file: /opt/civicrm/development.crt
    - require:
      - file: /opt/civicrm/Dockerfile
      - file: /opt/civicrm/development.crt
    - require_in:
      - docker_container: civicrm

# Run it with the stuff mounted read-only inside.
civicrm:
  docker_container.running:
    - name: civicrm
    - image: greenweb/civicrm:latest
    - extra_hosts: hydra.greenweb.ca:{{ pillar['docker']['static_ip'] }}
    - log_driver: syslog
#    - volumes: /var/www/html
    - restart_policy: always
    # - binds: /opt/civicrm/civicrm3:/var/www/html:rw
    - log_driver: syslog
    - log_opt:
        - tag: civicrm
    - networks:
        - production
    - watch:
        - docker_image: greenweb/civicrm
    - require:
        - docker_image: greenweb/civicrm

# Mount that volume somewhere useful so we can volume
# mount it into nginx. Note I could also copy this
# and treat it as an installation, mounting it into
# drupal-8 for multiple sites.

{% set op = '{{' %}
{% set cl = '}}' %}

civicrm_symlink:
  cmd.run:
    - name: 'docker inspect -f "{{ op }}range .Mounts{{ cl }}{{ op }}.Destination{{ cl }}:{{ op }}.Source{{ cl }}{{ op }}end{{ cl }}" civicrm | grep /var/www/html: | cut -d: -f 2 | xargs -i{} ln -s {} /opt/civicrm/webroot ;'
    - creates: /opt/civicrm/webroot
    - require:
        - docker_container: civicrm
