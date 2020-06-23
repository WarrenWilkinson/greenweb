# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set docker = salt['pillar.get']('telegraf:docker', false)  %}

include:
  - influxdb.repo
  {% if docker %}
  - docker
  {% endif %}

telegraf:
  pkg.installed:
    - refresh: True
    - require:
      - sls: influxdb.repo
  service.running:
    - enable: True
    - watch:
      - pkg: telegraf
      - file: /etc/telegraf/telegraf.conf
      - group: add-telegraf-to-docker

{% if docker %}
add-telegraf-to-docker:
  group.present:
    - name: docker
    - addusers:
      - telegraf
    - require:
      - pkg: telegraf
{% endif %}

/etc/telegraf/telegraf.conf:
  file.managed:
    - source: salt://telegraf/config/influxdb.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        hostname: {{ grains['id'] }}
        username: {{ pillar['telegraf']['influx_http']['username'] }}
        password: {{ pillar['telegraf']['influx_http']['password'] }}
        memory: {{ salt['pillar.get']('telegraf:memory', false) }}
        cpu: {{ salt['pillar.get']('telegraf:cpu', false) }}
        disk: {{ salt['pillar.get']('telegraf:disk', false)  }}
        docker: {{ docker }}
