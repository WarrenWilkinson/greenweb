# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

lxc.container_profile:
  standard_focal:
    template: download
    options:
      dist: ubuntu
      release: focal
      arch: amd64
    size: 1G
    script_args: "-x python3" # Needed for Focal
    # Adding these features doesn't work and I haven't had time to enable. -WW
    # backing: zfs
    # zfs_root: root.img

lxc.network_profile:
  standard_net:
    eth0:
      link: switch0 # Use openvswitch, not lxcbr0
      type: veth
      flags: up
      script.up: /etc/network/if-up.d/lxc-ifup
      script.down: /etc/network/if-post-down.d/lxc-ifdown
    # Adding these doesn't work and I don't know what they mean anyway -WW
    # gateway: 10.0.3.1
    # bridge: lxcbr0

  # ipv4.dhcp: "false"
  # ipv4.firewall: "false"
  # ipv4.nat: "false"
  # ipv6.address: ...
  # ipv6.dhcp: "false"
  # ipv6.firewall: "false"
  # ipv6.nat: "false"
