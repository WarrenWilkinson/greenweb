# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

# This sets up a 'null' postfix that forwards mail to the real server on postfix.

postfix:
  pkg.installed:
    - pkgs:
      - postfix
  service.running:
    - enable: true
    - watch:
      - pkg: postfix
      - file: /etc/postfix/main.cf

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/null_main.cf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        hostname: {{ grains.id }}
