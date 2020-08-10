# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set dev = true %}

{% if dev %}
{% set ssl_cert = '/opt/cert/development.crt' %}
{% set ssl_key = '/opt/cert/development.key' %}
{% endif %}

# Force postfix so we have the postfix user.
include:
  - postfix
{% if dev %}
  - cert.dev
{% endif %}

vmail:
  user.present:
    - shell: /usr/sbin/nologin
    - home: /var/mail/vhosts
    - createhome: True
    - groups:
      - shadow

/var/mail/attachments:
  file.directory:
    - user: vmail
    - group: vmail
    - mode: 770
    - require:
      - user: vmail

/var/mail/vhosts:
  file.directory:
    - user: vmail
    - group: vmail
    - mode: 770
    - require:
      - user: vmail

dovecot:
  pkg.installed:
    - pkgs:
      - dovecot-core
      - dovecot-imapd
      - dovecot-pop3d
      - dovecot-ldap
      - dovecot-lmtpd
      - dovecot-sieve
      - dovecot-managesieved
  service.running:
    - require:
      - pkg: dovecot
      - user: vmail

{% for file in ['10-mail', '10-master', '10-ssl', '15-mailboxes',
                '20-imap', '90-quota', '90-crypt', '10-auth',
                '95-trash'] %}
/etc/dovecot/conf.d/{{ file }}.conf:
  file.managed:
    - source: salt://dovecot/files/{{ file }}.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        ssl_cert: {{ ssl_cert }}
        ssl_key: {{ ssl_key }}
        user: vmail
        crypt_public_key: /opt/dovecot/ecpubkey.pem
        crypt_private_key: /opt/dovecot/ecprivkey.pem
        crypt_save_version: 2
    - watch_in:
      - service: dovecot
{% endfor %}

/etc/dovecot/dovecot-ldap.conf.ext:
  file.managed:
    - source: salt://dovecot/files/dovecot-ldap.conf.ext.jinja
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - defaults:
        ldap_password: {{ pillar['dovecot']['ldap']['password'] }}
        ldap_dn: {{ pillar['dovecot']['ldap']['dn'] }}
    - watch_in:
      - service: dovecot

/etc/dovecot/conf.d/auth-ldap.conf.ext:
  file.managed:
    - source: salt://dovecot/files/auth-ldap.conf.ext
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: dovecot

/etc/dovecot/conf.d/dovecot-trash.conf.ext:
  file.managed:
    - source: salt://dovecot/files/dovecot-trash.conf.ext
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: dovecot

/opt/dovecot/:
  file.directory:
    - user: dovecot
    - group: dovecot
    - mode: 777
    - require:
      - pkg: dovecot

/opt/dovecot/ecprivkey.pem:
  file.managed:
    - source: salt://dovecot/files/ecprivkey.pem
    - user: dovecot
    - group: dovecot
    - mode: 444
    - watch_in:
      - service: dovecot
    - require:
      - file: /opt/dovecot/

/opt/dovecot/ecpubkey.pem:
  file.managed:
    - source: salt://dovecot/files/ecpubkey.pem
    - user: dovecot
    - group: dovecot
    - mode: 444
    - watch_in:
      - service: dovecot
    - require:
      - file: /opt/dovecot/

/usr/local/bin/quota-warning.sh:
  file.managed:
    - source: salt://dovecot/files/quota-warning.sh
    - user: root
    - group: root
    - mode: 755
