# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

dnsmasq:
  pkg.installed:
    - refresh: True
  service.running:
    - enable: True
    - watch:
      - pkg: dnsmasq
      - service: systemd-resolved
      - file: /etc/dnsmasq.conf

# This is a systemd resolver for domain names. We need to tweak it
# to not bind the DNS port so that dnsmasq can have it.
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
        domain: {{ config.internal_domain }}
        gateway: 10.0.3.1
        dhcp_range_min: 10.0.3.120
        dhcp_range_max: 10.0.3.200
        dhcp_duration: infinite
        static_ips:
          docker: {{ config.docker.internal_ip }}
          postfix: {{ config.postfix.internal_ip }}
    - require:
      - pkg: dnsmasq
