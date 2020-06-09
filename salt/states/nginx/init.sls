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

# Setup nginx to have sites-enabled, sites-available structure
# and get rid of the default site.

/etc/nginx/sites-available:
  file.directory:
    - user: root
    - group: root
    - mode: 755

/etc/nginx/sites-enabled:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - watch_in:
      - service: nginx

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/config/nginx.conf
    - user: root
    - group: root
    - mode: 755
    - watch_in:
      - service: nginx

/etc/nginx/conf.d:
  file.absent:
    - source: salt://nginx/config/nginx.conf
    - user: root
    - group: root
    - mode: 755

# Reverse Proxy Grafana

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

/etc/nginx/sites-available/grafana.conf:
  file.managed:
    - source: salt://nginx/config/nginx_grafana.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /etc/nginx/sites-available
    - watch_in:
      - service: nginx

/etc/nginx/sites-enabled/grafana.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/grafana.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /etc/nginx/sites-available/grafana.conf
    - watch_in:
      - service: nginx
