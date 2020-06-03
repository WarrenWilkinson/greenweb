lxc-net:
  pkg.installed:
    - name: lxc
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/lxc-net
      - file: /etc/lxc/dnsmasq.conf
      - pkg: lxc

/etc/default/lxc-net:
  file.managed:
    - source: salt://lxc/files/lxc-net
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: lxc

/etc/lxc/dnsmasq.conf:
  file.managed:
    - source: salt://lxc/files/dnsmasq.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: lxc

salt:
  host.present:
    - ip: 10.0.3.2
