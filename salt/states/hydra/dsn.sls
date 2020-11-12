# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set domain = config.internal_domain %}

{% set hydra_user = pillar['hydra']['database']['username'] %}
{% set hydra_password = pillar['hydra']['database']['password'] %}
{% set hydra_database = pillar['hydra']['database']['database'] %}
{% set secret = pillar['hydra']['secret'] %}

{% set dsn = 'postgres://' + hydra_user + ':' + hydra_password + '@postgresql.' + domain + ':5432/' + hydra_database + '?sslmode=disable' %}
