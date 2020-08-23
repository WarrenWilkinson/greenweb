# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

/opt/phpbb:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/phpbb/Dockerfile:
  file.managed:
    - source: salt://phpBB/files/Dockerfile
    - user: root
    - group: root
    - mode: 644

greenweb/phpbb:
  docker_image.present:
    - build: /opt/phpbb
    - tag: latest
    - require:
      - file: /opt/phpbb/Dockerfile
    - require_in:
      - docker_container: phpbb

phpbb:
  docker_container.running:
    - name: phpbb
    - image: greenweb/phpbb:latest
    - log_driver: syslog
    - restart_policy: always
    - networks:
        - production
    - require:
        - docker_image: greenweb/phpbb
