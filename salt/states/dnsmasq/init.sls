# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

# This is a systemd resolver for domain names. We need to disable it
# to use dnsmasq.

dnsmasq:
  pkg.installed:
    - refresh: True
  service.running:
    - enable: True
    - watch:
      - pkg: dnsmasq
      - service: systemd-resolved
      - file: /etc/dnsmasq.conf

systemd-resolved:
  service.running:
    - enable: true
    - watch:
       - file: /etc/systemd/resolved.conf

/etc/systemd/resolved.conf:
  file.managed:
    - source: salt://dnsmasq/files/resolved.conf
    - user: root
    - group: root
    - mode: 644

/etc/dnsmasq.conf:
  file.managed:
    - source: salt://dnsmasq/files/dnsmasq.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        domain: greenweb.ca
        gateway: 10.0.3.1
        dhcp_range_min: 10.0.3.120
        dhcp_range_max: 10.0.3.200
        dhcp_duration: 12h
        nginx_static_ip: {{ pillar['nginx']['static_ip'] }}
    - require:
      - pkg: dnsmasq
