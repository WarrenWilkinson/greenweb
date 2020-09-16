# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

# Build a generic php-fpm image This can probably be extracted out and
# used for other projects. Wordpress for example.

/opt/php:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/php/Dockerfile:
  file.managed:
    - source: salt://phpbb/files/Dockerfile
    - user: root
    - group: root
    - mode: 644

/opt/php/development.crt:
  file.managed:
    - source: salt://cert/files/development.crt
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /opt/php

greenweb/phpbb:
  docker_image.present:
    - build: /opt/php
    - tag: latest
    - watch:
      - file: /opt/php/Dockerfile
      - file: /opt/php/development.crt
    - require:
      - file: /opt/php/Dockerfile
      - file: /opt/php/development.crt
    - require_in:
      - docker_container: phpbb

# Download and install phpbb
/opt/phpbb/:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/opt/phpbb/phpBB-3.3.1.tar.bz2:
  file.managed:
    - source: https://download.phpbb.com/pub/release/3.3/3.3.1/phpBB-3.3.1.tar.bz2
    - source_hash: b778456e3844a09e6bfe9b9b1b9968f9a19085b5a89b3bcb2d82c36e7424f7ae
    - require:
        - file: /opt/phpbb/

extract_phpBB-3.3.1:
  archive.extracted:
    - name: /opt/phpbb/
    - source: /opt/phpbb/phpBB-3.3.1.tar.bz2
    - user: www-data
    - group: www-data
    - if_missing: /opt/phpbb/phpBB3/

# Add oauth code for greenweb.
/opt/phpbb/phpBB3/phpbb/auth/provider/oauth/service/greenweb.php:
  file.managed:
    - source: salt://phpbb/files/greenweb.php
    - user: www-data
    - group: www-data
    - mode: 644
    - require:
        - archive: extract_phpBB-3.3.1

/opt/phpbb/phpBB3/phpbb/auth/provider/oauth/service/GreenwebOauth.php:
  file.managed:
    - source: salt://phpbb/files/GreenwebOauth.php
    - user: www-data
    - group: www-data
    - mode: 644
    - template: jinja
    - defaults:
        oauth_auth_url: https://hydra.greenweb.ca/oauth2/auth?login_challenge=phpbb
        oauth_token_url: https://hydra.greenweb.ca/oauth2/token
        oauth_base_uri: https://hydra.greenweb.ca/
    - require:
        - archive: extract_phpBB-3.3.1

/opt/phpbb/phpBB3/config/default/container/services_auth.yml:
  file.append:
    - text: |
        # ----- Greenweb OAuth service providers -----
            auth.provider.oauth.service.greenweb:
                class: phpbb\auth\provider\oauth\service\greenweb
                arguments:
                    - '@config'
                    - '@request'
                tags:
                    - { name: auth.provider.oauth.service }
    - require:
        - archive: extract_phpBB-3.3.1

# Run it with the stuff mounted read-only inside.
phpbb:
  docker_container.running:
    - name: phpbb
    - image: greenweb/phpbb:latest
    - extra_hosts: hydra.greenweb.ca:{{ pillar['docker']['static_ip'] }}
    - log_driver: syslog
    - restart_policy: always
    - binds: /opt/phpbb/phpBB3:/var/www/html:rw
    - log_driver: syslog
    - log_opt:
        - tag: phpbb
    - networks:
        - production
    - watch:
        - docker_image: greenweb/phpbb
    - require:
        - docker_image: greenweb/phpbb
        - file: /opt/phpbb/phpBB3/phpbb/auth/provider/oauth/service/greenweb.php
        - file: /opt/phpbb/phpBB3/phpbb/auth/provider/oauth/service/GreenwebOauth.php
        - file: /opt/phpbb/phpBB3/config/default/container/services_auth.yml
