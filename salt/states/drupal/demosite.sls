# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

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
{% set smtp_user = config.drupal.smtp.username %}
{% set smtp_password = salt['pillar.get']('drupal:smtp:password') %}

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
        account_mail: postmaster@{{ domain }}
        site_name: Drupal
        site_mail: drupal@{{ domain }}
        log_name: drupal_demo
        smtp_host: postfix.{{ domain }}
        smtp_port: 587
        smtp_username: {{ smtp_user }}
        smtp_password: {{ smtp_password }}
        oauth_client_id: {{ clientid }}
        oauth_secret: {{ clientsecret }}
        oauth_auth_endpoint: https://hydra.{{ domain }}/oauth2/auth?login_challenge=drupal
        oauth_token_endpoint: https://hydra.{{ domain }}/oauth2/token
        oauth_userinfo_endpoint: https://hydra.{{ domain }}/userinfo

/var/www/html/sites/default/settings.php:
  file.append:
    - text: |
        $settings['trusted_host_patterns'] = [
           '^drupal\.{{ config.internal_organization }}\.{{ config.internal_toplevel_domain }}$',
        ];
        $settings['file_private_path'] = '/opt/private/';
