# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

include:
  - docker

{% from 'hydra/dsn.sls' import dsn %}

provision:
  docker_container.run:
    - image: oryd/hydra:v1.5.2
    - command: migrate sql --yes {{ dsn }}
    - replace: True
