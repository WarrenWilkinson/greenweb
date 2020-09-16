# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - phpBB.dockerized

# Add configuration file
{% set phpbb_dbuser = pillar['phpbb']['database']['username'] %}
{% set phpbb_dbport = pillar['phpbb']['database']['port'] %}
{% set phpbb_dbpassword = pillar['phpbb']['database']['password'] %}
{% set phpbb_database = pillar['phpbb']['database']['database'] %}

{% set phpbb_admin_username = pillar['phpbb']['admin']['username'] %}
{% set phpbb_admin_password = pillar['phpbb']['admin']['password'] %}

/opt/phpbb/phpBB3/install/install-config.yml:
  file.managed:
    - source: salt://phpBB/files/install.yml.jinja
    - user: www-data
    - group: www-data
    - mode: 644
    - template: jinja
    - defaults:
        admin_name: {{ phpbb_admin_username }}
        admin_password: {{ phpbb_admin_password }}
        admin_email: postmaster@greenweb.ca
        board_lang: en
        board_name: Greenweb Forum
        board_description: Forum for Tri-Cities Greenweb
        database_provider: postgres
        database_host: postgresql.greenweb.ca
        database_port: {{ phpbb_dbport }}
        database_user: {{ phpbb_dbuser }}
        database_password: {{ phpbb_dbpassword }}
        database_name: {{ phpbb_database }}
        database_prefix: phpbb_
        smtp_enabled: true
        smtp_delivery: true
        smtp_host: postfix.greenweb.ca
        smtp_port: 587
        smtp_auth: false
        smtp_user: ~
        smtp_pass: ~
        server_cookie_secure: true
        server_protocol: https://
        server_name: forum.greenweb.ca
        server_port: 443
        server_script_path: /
        extensions: [] # ['phpbb/viglink']

# docker run --rm -ti -v  /opt/phpbb/phpBB3:/var/www/html greenweb/php /bin/bash
provision:
  docker_container.run:
    - name: phpbb_provision
    - image: greenweb/phpbb:latest
    - binds: /opt/phpbb/phpBB3:/var/www/html:rw
    - command: /bin/sh -c 'cd /var/www/html/; php install/phpbbcli.php install install/install-config.yml && chown www-data:www-data -R /var/www/html'
# this file seems to already exist, which stops this from running.
#    - creates: /opt/phpbb/phpBB3/config.php
    - replace: True
    - require:
        - file: /opt/phpbb/phpBB3/install/install-config.yml

# Remove the install directory upon success...
/opt/phpbb/phpBB3/install/:
  file.absent:
    - require:
        - docker_container: provision

# Put in the greenweb oauth credentials
# The values are stored in the database:
# select * from phpbb_config where config_name like 'auth_oauth_greenweb%';
#         config_name         | config_value | is_dynamic 
# ----------------------------+--------------+------------
#  auth_oauth_greenweb_key    | hello        |          0
#  auth_oauth_greenweb_secret | goodbye      |          0
# (2 rows)
# Not sure where to enter this though.

salt://phpBB/files/configure.sql:
  cmd.script:
    - template: jinja
    - defaults:
        prefix: phpbb_
        oauth_secret: {{ pillar['hydra']['client_secret']['phpbb'] }}
    - shell: /usr/bin/psql-exec
    - env:
        - PGUSER: {{ phpbb_dbuser }}
        - PGDATABASE: {{ phpbb_database }}
        - PGPORT: {{ phpbb_dbport }}
        - PGPASSWORD: {{ phpbb_dbpassword }}
        - PGHOST: postgresql.greenweb.ca
    - args: "--single-transaction --no-password"
    - require:
        - file: /opt/phpbb/phpBB3/install/
        - docker_container: provision


