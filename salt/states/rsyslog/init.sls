# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set config_file = 'collector.conf' if ( grains.id == 'logging') else 'sender.conf' %}

rsyslog:
  pkg.installed:
    - name: rsyslog
  service.running:
    - enable: True
    - watch:
      - file: /etc/rsyslog.d/{{ config_file }}

/etc/rsyslog.d/{{ config_file }}:
  file.managed:
    - source: salt://rsyslog/config/{{ config_file }}
    - user: root
    - group: root
    - mode: 644
