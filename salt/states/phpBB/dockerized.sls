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
    - source: salt://phpBB/files/Dockerfile
    - user: root
    - group: root
    - mode: 644

greenweb/phpbb:
  docker_image.present:
    - build: /opt/php
    - tag: latest
    - watch:
      - file: /opt/php/Dockerfile
    - require:
      - file: /opt/php/Dockerfile
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
    - source: salt://phpBB/files/greenweb.php
    - user: www-data
    - group: www-data
    - mode: 644
    - require:
        - archive: extract_phpBB-3.3.1

/opt/phpbb/phpBB3/phpbb/auth/provider/oauth/service/GreenwebOauth.php:
  file.managed:
    - source: salt://phpBB/files/GreenwebOauth.php
    - user: www-data
    - group: www-data
    - mode: 644
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
