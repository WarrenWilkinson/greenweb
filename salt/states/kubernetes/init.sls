# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set dbuser = pillar['kubernetes']['database']['username'] %}
{% set dbpass = pillar['kubernetes']['database']['password'] %}
{% set dbhost = pillar['kubernetes']['database']['hostname'] %}
{% set dbport = pillar['kubernetes']['database']['port'] %}
{% set dbname = pillar['kubernetes']['database']['database'] %}

curl:
  pkg.installed

install:
  cmd.run:
    - creates: /opt/keycloak-10.0.2
    - cwd: /tmp/
    - name: curl -sfL https://get.k3s.io | sh -s - --disable-network-policy --disable-cloud-controller --disable metrics-server --datastore-endpoint postgres://{{ dbuser }}:{{ dbpass }}@{{ dbhost }}:{{ dbport }}/{{ dbname }}


# TODO Install heapster to collect data.
# TODO Move grafana into kubernetes.
