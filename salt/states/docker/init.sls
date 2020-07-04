# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

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
    - subnet: {{ pillar['docker']['subnet'] }}
    - gateway: {{ pillar['docker']['gateway'] }}
    - iprange: {{ pillar['docker']['iprange'] }}
