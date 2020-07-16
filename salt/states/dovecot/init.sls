# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

dovecot:
  pkg.installed:
    - pkgs:
      - dovecot-core
      - dovecot-imapd
      - dovecot-pop3d
      - dovecot-ldap
      # sieve? managesieved? -- Yes, but not right now. Maybe never.
  service.running:
    - require:
      - pkg: dovecot

vmail:
  user.present:
    - shell: /usr/sbin/nologin
    - home: /var/mail/vhosts
    - createhome: True

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
