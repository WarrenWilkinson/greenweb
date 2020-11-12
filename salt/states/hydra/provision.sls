# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

include:
  - hydra.dockerized

# Need to add commands to import json files that define the clients...
# NOTE: In production, I don't need to normally expose
# hydra.
{% for site in ['grafana', 'phpbb', 'drupal'] %}
/tmp/{{ site }}.json:
  file.managed:
    - source: salt://hydra/clients/hydra_{{ site }}.json.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        client_id: {{ site }}
        client_secret: {{ pillar['hydra']['client_secret'][site] }}
        domain: {{ config.internal_domain }}

remove_{{ site }}:
  docker_container.run:
    - image: oryd/hydra:v1.5.2
    - replace: True
    - binds:
        - /tmp/:/tmp/:ro
    - entrypoint:
        - hydra
        - clients
        - --fake-tls-termination
        - delete
        - {{ site }}
    - environment:
      - HYDRA_URL: http://hydra:4445/
    - networks:
        - production
    - require:
        - file: /tmp/{{ site }}.json
        - docker_container: hydra

provision_{{ site }}:
  docker_container.run:
    - image: oryd/hydra:v1.5.2
    - replace: True
    - binds:
        - /tmp/:/tmp/:ro
    - entrypoint:
        - hydra
        - clients
        - --fake-tls-termination
        - import
        - /tmp/{{ site }}.json
    - environment:
      - HYDRA_URL: http://hydra:4445/
    - networks:
        - production
    - require:
        - file: /tmp/{{ site }}.json
        - docker_container: remove_{{ site }}
        - docker_container: hydra

# delete_{{ site }}.json:
#   file.absent:
#     - name: /tmp/{{ site }}.json
#     - require:
#       - file: /tmp/{{ site }}.json
#       - docker_container: remove_{{ site }}
#       - docker_container: provision_{{ site }}

# cleanup_docker_{{ site }}:
#   docker_container.absent:
#     - names:
#       - provision_{{ site }}
#       - remove_{{ site }}
#     - require:
#       - docker_container: remove_{{ site }}
#       - docker_container: provision_{{ site }}

{% endfor %}

# WORKS:
# docker run --rm -it --network production -e HYDRA_URL=http://hydra:4445/ --entrypoint hydra oryd/hydra:v1.5.2 clients list --fake-tls-termination
# docker run --rm -it --network production -e HYDRA_URL=http://hydra:4445/ --entrypoint hydra oryd/hydra:v1.5.2 clients delete --fake-tls-termination bf105808-f4a7-4e40-babe-09e030883139
# docker run --rm -it --network production -e HYDRA_URL=http://hydra:4445/ --entrypoint hydra oryd/hydra:v1.5.2 clients get --fake-tls-termination grafana

# docker run --rm -it --network production -e HYDRA_URL=http://hydra:4445/ --entrypoint hydra oryd/hydra:v1.5.2 clients create --fake-tls-termination \
#     --id grafana \
#     --secret test-secret \
#     --grant-types authorization_code,refresh_token,client_credentials,implicit \
#     --response-types token,code,id_token \
#     --scope openid,offline \
#     --callbacks https://grafana.greenweb.ca/login/generic_oauth
