# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

# Note that we turn off lxc-net in order
# to not depend on iptables.  We're using
# nftables instead, which is Linux's more
# recent firewall interface.

# Do this first, customizations won't be overridden.
# and we can turn off lxc-net before it makes the bridge
# network.
/etc/default/lxc-net:
  file.managed:
    - source: salt://lxc/files/lxc-net
    - user: root
    - group: root
    - mode: 644

lxc-net:
  pkg.installed:
    - name: lxc
  service:
    - dead
    - enable: False
    - watch:
      - file: /etc/default/lxc-net
      - file: /etc/lxc/dnsmasq.conf
      - pkg: lxc

/etc/lxc/dnsmasq.conf:
  file.managed:
    - source: salt://lxc/files/dnsmasq.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: lxc

# Use openwswitch for the bridge network
openvswitch-switch:
  pkg.installed

ovs-vswitchd:
  service:
    - running
    - enable: True

# Need to make the below persistant
#sudo ip addr add 10.0.3.1/24 dev switch0

# Create the switch, pre-create a port with address 10.0.3.1 for the DNSMASQ instance.
switch0:
  openvswitch_bridge.present

# switch0_nework:    
#   network.managed:
#     - enabled: True
#     - type: vlan # ovs
#     - proto: static
#     # - enable_ipv6: true
#     - ipv6proto: static
#     # - ipv6ipaddrs:
#     #   - 2001:db8:dead:beef::3/64
#     #   - 2001:db8:dead:beef::7/64
#     # - ipv6gateway: 2001:db8:dead:beef::1
#     # - ipv6netmask: 64
#     - dns:
#       - 8.8.8.8
#       - 8.8.4.4
#     # - proto: static
#     - ipaddr: 10.0.3.1
#     - netmask: 255.255.255.0
#     - gateway: 10.0.3.1
#     # - enable_ipv6: true
#     # - ipv6proto: static
#     # - ipv6ipaddrs:
#     #   - 2001:db8:dead:beef::3/64
#     #   - 2001:db8:dead:beef::7/64
#     # - ipv6gateway: 2001:db8:dead:beef::1
#     # - ipv6netmask: 64
#     # - dns:
#     #   - 8.8.8.8
#     #   - 8.8.4.4

# lxcbr0:
#   openvswitch_port.present
#    - bridge: switch0
#    - remote: 10.0.3.1
#    - internal: true

/etc/netplan/02-switch0-netplan.yaml:
  file.managed:
    - source: salt://lxc/files/02-switch0-netplan.yaml.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        domain: {{ config.internal_domain }}
        gateway: {{ pillar['openvswitch']['gateway'] }}
        nameserver: {{ pillar['openvswitch']['nameserver'] }}

'netplan apply':
  cmd.run:
    - watch:
       - file: /etc/netplan/02-switch0-netplan.yaml

# Scripts for LXC containers to attach to the bridge network
/etc/network/if-up.d/lxc-ifup:
  file.managed:
    - source: salt://lxc/files/lxc-ifup
    - user: root
    - group: root
    - mode: 755

/etc/network/if-post-down.d/lxc-ifdown:
  file.managed:
    - source: salt://lxc/files/lxc-ifdown
    - user: root
    - group: root
    - mode: 755

# And setup a dnsmasq dhcp server so that machines can bootup nicely.
