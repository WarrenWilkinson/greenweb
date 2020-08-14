# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

logrotate:
  pkg.installed

{% if grains.id == 'logging' %}
/etc/logrotate.d/general-logs:
  file.managed:
    - source: salt://logrotate/files/general-logs
    - user: root
    - group: root
    - mode: 644
{% endif %}
