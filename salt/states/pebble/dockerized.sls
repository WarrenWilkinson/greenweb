# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

/opt/pebble:
  file.directory:
    - user: root
    - group: root
    - mode: 755


/opt/pebble/config.json:
  file.managed:
    - source: salt://pebble/files/config.json
    - user: root
    - group: root
    - mode: 644

pebble:
  docker_container.running:
    - name: pebble
    - image: letsencrypt/pebble
    - command: pebble -config /test/my-pebble-config.json
    - binds:
        - /opt/pebble/config.json:/test/my-pebble-config.json:ro
    # Note that PEBBLE is NOT ON THE production network.
    # So its ports must be exposed.
    - port_bindings:
      - 14000:14000
      - 15000:15000
    - environment:
      - PEBBLE_VA_NOSLEEP=1
    - log_driver: syslog
    - log_opt:
        - tag: pebble
    - restart_policy: always
    - watch:
      - file: /opt/pebble/config.json
