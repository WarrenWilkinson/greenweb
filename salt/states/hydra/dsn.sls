# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% set hydra_user = pillar['hydra']['database']['username'] %}
{% set hydra_password = pillar['hydra']['database']['password'] %}
{% set hydra_database = pillar['hydra']['database']['database'] %}
{% set secret = pillar['hydra']['secret'] %}

{% set dsn = 'postgres://' + hydra_user + ':' + hydra_password + '@postgresql.greenweb.ca:5432/' + hydra_database + '?sslmode=disable' %}
