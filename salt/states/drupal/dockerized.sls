# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

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

# # Copy the basic Drupal files out.
# /opt/drupal/base:
#   file.directory:
#     - user: root
#     - group: root
#     - mode: 755

# /opt/drupal/base/html:
#   docker_container.run:
#     - name: drupal
#     - image: greenweb/drupal:latest
#     - creates: /opt/drupal/base/html
#     - binds:
#         - /opt/drupal/base:/tmp/base
#     - command: cp -rp /var/www/html /tmp/base
#     - require:
#       - file: /opt/drupal/base

# Now, provision it:
# TODO: Find a way to pass in either a pillarenvironment or the pillar itself
# and avoid the translation. The pillar command doesn't seem to work, it picks
# up the host's pillar... So, copy paste I guess.
# NOTE: If this step fails -- has the database already been provisioned?
# because it will fail if it has.
# greenweb/drupaldemo:
#   docker_image.present:
#     - tag: latest
#     - sls: "rsyslog,drupal.demosite"
#     - base: greenweb/drupal:latest
#     - watch:
#         - docker_image: greenweb/drupal
#     - require:
#         - docker_image: greenweb/drupal

# /opt/drupal/demo_private:
#   file.directory:
#     - user: root
#     - group: root
#     - mode: 755

# Drupal, because of the volume, I think
# seems to require much longer to start.
# set_docker_timeout:
#   environ.setenv:
#     - name: DOCKER_CLIENT_TIMEOUT
#     - value: "300"
#     - update_minion: True

# Run it with the stuff mounted read-only inside.
# drupaldemo:
#   docker_container.running:
#     - name: drupaldemo
#     - image: greenweb/drupaldemo:latest
#     - extra_hosts: hydra.greenweb.ca:{{ pillar['docker']['static_ip'] }}
#     - restart_policy: always
#     - log_driver: syslog
#     - log_opt:
#         - tag: drupaldemo
#     - client_timeout: 300
#     - binds:
#         - /opt/drupal/demo_webhome:/var/www/html
#         - /opt/drupal/demo_private:/opt/private
#     - networks:
#         - production
#     - watch:
#         - docker_image: greenweb/drupaldemo
#     - require:
#         - docker_image: greenweb/drupaldemo
#         - file: /opt/drupal/demo_private

# Mount that volume somewhere useful so we can volume
# mount it into nginx. Note I could also copy this
# and treat it as an installation, mounting it into
# drupal-8 for multiple sites.

# {% set op = '{{' %}
# {% set cl = '}}' %}
  
# drupaldemo_symlink:
#   cmd.run:
#     - name: 'docker inspect -f "{{ op }}range .Mounts{{ cl }}{{ op }}printf \"%s:%s\n\" .Destination .Source {{ cl }}{{ op }}end{{ cl }}" drupaldemo | grep /var/www/html: | cut -d: -f 2 | xargs -i{} ln -s {} /opt/drupal/demo_webroot ;'
#     - creates: /opt/drupal/demo_webroot
#     - require:
#         - docker_container: drupaldemo
