# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

docker.io:
  pkg.installed

python3-docker:
  pkg.installed

add-ubuntu-to-docker:
  group.present:
    - name: docker
    - addusers:
      - ubuntu
    - require:
      - pkg: docker.io

network_production:
  docker_network.present:
    - name: production
    - subnet: {{ config.docker.subnet }}
    - gateway: {{ config.docker.gateway }}
    - iprange: {{ config.docker.ip_range }}
