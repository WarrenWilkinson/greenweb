# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set org = config.internal_organization %}
{% set domain = config.internal_domain %}
{% set tl = config.internal_toplevel_domain %}

{% set ssl_primary_domain = config.postfix.ssl_primary_domain %}
{% set ssl_cert = config.postfix.ssl_cert %}
{% set ssl_key = config.postfix.ssl_key %}

{% if config.letsencrypt.use_pebble == true %}
include:
  - cert.pebble
{% endif %}

certbot:
  pkg.installed

{{ ssl_primary_domain }}:
  acme.cert:
{% if config.letsencrypt.use_pebble == true %}
    - server: https://pebble:14000/dir
{% endif %}
    # - aliases:
    #   - gitlab.example.com
    - email: {{ config.letsencrypt.email }}
    - renew: 60

postfix:
  pkg.installed:
    - pkgs:
      - postfix
      - postfix-ldap
  service.running:
    - enable: true
    - require:
      - acme: postfix.{{ domain }}
    - watch:
      - pkg: postfix
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/master.cf

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/main.cf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        relay_domains:
          {{ config.postfix.relay_domains }}
        domain: {{ domain }}
        ssl_cert: {{ ssl_cert }}
        ssl_key: {{ ssl_key }}
        openvswitch_network: {{ pillar['openvswitch']['network'] }}
        external_ip: {{ pillar['external_ip'] }}

/etc/postfix/ldap:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: postfix

{% for file in ['virtual_mailbox_maps', 'virtual_alias_maps'] %}
/etc/postfix/ldap/{{ file }}.cf:
  file.managed:
    - source: salt://postfix/files/{{ file }}.cf.jinja
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - defaults:
        ldap_bind_dn: {{ pillar['postfix']['ldap']['dn'] }}
        ldap_bind_password: {{ pillar['postfix']['ldap']['password'] }}
        ldap_base: ou=email,dc={{ org }},dc={{ tl }}
        ldap_host: ldap.{{ domain }}
    - watch_in:
      - service: postfix
    - require:
      - file: /etc/postfix/ldap
{% endfor %}

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/master.cf
    - user: root
    - group: root
    - mode: 644
