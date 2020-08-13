# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

fail2ban:
  pkg.installed:
    - pkgs:
      - fail2ban
  service.running:
    - require:
      - pkg: fail2ban

/etc/fail2ban/fail2ban.local:
  file.managed:
    - source: salt://fail2ban/files/fail2ban.local.jinja
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - watch_in:
      - service: fail2ban

/etc/fail2ban/jail.d/customizations.local:
  file.managed:
    - source: salt://fail2ban/files/customizations.local.jinja
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - defaults:
        openvswitch_network: {{ pillar['openvswitch']['network'] }}
        vmhost_hostname: ubuntu2004
    - watch_in:
      - service: fail2ban
