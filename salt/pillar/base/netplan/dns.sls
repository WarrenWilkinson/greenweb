# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

netplan:
  static: true
  interface: eth0
  ip4: 10.0.3.2
  gateway4: 10.0.3.1
  file: /etc/netplan/10-lxc.yaml
  nameservers:
    # search: [greenweb.ca] # Now in by configuration.yaml, just config.internal_domain.
    addresses: [127.0.0.1]
