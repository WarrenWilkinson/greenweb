# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:1.19.0
    - port_bindings:
      - 80:80
      - 443:443
    - log_driver: syslog
    - restart_policy: always
