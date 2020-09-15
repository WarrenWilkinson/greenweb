# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - drupal.dockerized

/opt/drupal/demo:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/drupal/demo/private:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - require:
        - file: /opt/drupal/demo

/opt/drupal/demo/private/.htaccess:
  file.managed:
    - mode: 644
    - user: www-data
    - group: www-data
    - source: salt://drupal/files/private_htaccess
    - require:
        - file: /opt/drupal/demo

greenweb/drupaldemo:
  docker_image.present:
    - tag: latest
    - sls: "drupal.demosite"
    - base: greenweb/drupal:latest
    - watch:
        - docker_image: greenweb/drupal
    - require:
        - docker_image: greenweb/drupal

/opt/drupal/demo/web:
  docker_container.run:
    - name: drupaldemo-cp
    - replace: True
    - auto_remove: True
    - image: greenweb/drupaldemo:latest
    - creates: /opt/drupal/demo/web
    - binds:
        - /opt/drupal/demo:/tmp/base
    - command: cp -rp /opt/drupal/web /tmp/base
    - require:
      - file: /opt/drupal/demo
      - docker_image: greenweb/drupaldemo

drupaldemo:
  docker_container.running:
    - name: drupaldemo
    - image: greenweb/drupaldemo:latest
    - extra_hosts: hydra.greenweb.ca:{{ pillar['docker']['static_ip'] }}
    - restart_policy: always
    - log_driver: syslog
    - log_opt:
        - tag: drupaldemo
    - command: php-fpm
    - binds:
        - /opt/drupal/demo/web:/opt/drupal/web
        - /opt/drupal/demo/private:/opt/private
    - networks:
        - production
    - watch:
        - docker_image: greenweb/drupaldemo
    - require:
        - docker_container: /opt/drupal/demo/web
        - file: /opt/drupal/demo/private
