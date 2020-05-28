# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

nginx:
  pkgrepo.managed:
    - humanname: Nginx Upstream Repository
    - name: deb https://nginx.org/packages/ubuntu/ bionic nginx
    - dist: bionic
    - file: /etc/apt/sources.list.d/nginx.list
    - gpgcheck: 1
    - keyid: ABF5BD827BD9BF62
    - keyserver: keyserver.ubuntu.com
    - require_in:
       - pkg: nginx
  pkg.latest:
    - name: nginx
    - refresh: True
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: nginx

# Next thing to do is to configure
# nginx to forward grafana so that
# I can start looking at it.

# Then I want to configure grafana
# and telegraf to start reporting
# on nginx and other things.

# Finally, then I want to configure
# telegraf on vagrant.vm and monitor
# the system usage as well.  That
# should be enough.

# Lastly, what about alerts from
# my logs?  Yes, there is ommail.
# But perhaps set this up later
# when I have more experience.
