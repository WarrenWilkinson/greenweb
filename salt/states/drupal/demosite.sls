# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

# Add configuration file
{% set dbuser = salt['pillar.get']('drupal:database:username', 'username-not-set') %}
{% set dbport = salt['pillar.get']('drupal:database:port', 'qux')  %}
{% set dbpassword = salt['pillar.get']('drupal:database:password', 'password-not-set') %}
{% set database = salt['pillar.get']('drupal:database:database', 'database-not-set') %}
{% set dbhost = salt['pillar.get']('drupal:database:hostname', 'hostname-not-set') %}
{% set clientid = 'drupal' %}
{% set clientsecret = salt['pillar.get']('hydra:client_secret:drupal', 'secret-not-set') %}

{% set admin_user = salt['pillar.get']('drupal:admin:username') %}
{% set admin_password = salt['pillar.get']('drupal:admin:password') %}

setup:
  cmd.script:
    - cwd: /var/www/html
    - source: salt://drupal/files/demosite-setup.sh
    - template: jinja
    - defaults:
        dbuser: {{ dbuser }}
        dbport: {{ dbport }}
        dbpassword: {{ dbpassword }}
        database: {{ database }}
        dbhost: {{ dbhost }}
        account_name: {{ admin_user }}
        account_pass: {{ admin_password }}
        account_mail: postmaster@greenweb.ca
        site_name: Drupal
        site_mail: drupal@greenweb.ca
        log_name: drupal_demo
        smtp_host: postfix.greenweb.ca
        smtp_port: 25
        oauth_client_id: {{ clientid }}
        oauth_secret: {{ clientsecret }}
        oauth_auth_endpoint: https://hydra.greenweb.ca/oauth2/auth?login_challenge=drupal
        oauth_token_endpoint: https://hydra.greenweb.ca/oauth2/token
        oauth_userinfo_endpoint: https://hydra.greenweb.ca/userinfo

/var/www/html/sites/default/settings.php:
  file.append:
    - text: |
        $settings['trusted_host_patterns'] = [
           '^drupal\.greenweb\.ca$',
        ];
        $settings['file_private_path'] = '/opt/private/';
