# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

nftables:
  pkg.installed:
    - name: nftables
  service.running:
    - enable: True
    - watch:
      - file: /etc/nftables.conf

/etc/nftables.conf:
  file.managed:
    - source: salt://nft/files/nftables.conf.jinja
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - defaults:
        ssh_port: {{ pillar['nft']['ssh_port'] }}
        lxc_bridge: switch0
        primary_interface: eth0
        secondary_interface: eth1 # static vagrant IP.
        lxc_docker_ip: {{ pillar['docker']['static_ip'] }}

# Enable Packet forwarding
/etc/sysctl.d/15-enable-ip-forward.conf:
  file.managed:
    - source: salt://nft/files/15-enable-ip-forward.conf
    - user: root
    - group: root
    - mode: 644

procps:
  service.running:
    - enable: True
    - watch:
       - file: /etc/sysctl.d/15-enable-ip-forward.conf

# Disable the Ubuntus ufw (iptables)
ufw:
  service.dead:
    - enable: False

/etc/modprobe.d/blacklist-iptables.conf:
  file.managed:
    - source: salt://nft/files/blacklist-iptables.conf
    - user: root
    - group: root
    - mode: 644

# Blacklisting wasn't enough, so delete the kernel modules.
/lib/modules/4.15.0-58-generic/kernel/net/ipv4/netfilter/iptable_filter.ko:
  file.absent

/lib/modules/4.15.0-58-generic/kernel/net/ipv4/netfilter/iptable_mangle.ko:
  file.absent

/lib/modules/4.15.0-58-generic/kernel/net/ipv4/netfilter/iptable_nat.ko:
  file.absent

/lib/modules/4.15.0-58-generic/kernel/net/ipv4/netfilter/iptable_raw.ko:
  file.absent

/lib/modules/4.15.0-58-generic/kernel/net/ipv4/netfilter/iptable_security.ko:
  file.absent

/lib/modules/4.15.0-58-generic/kernel/net/ipv4/netfilter/ip_tables.ko:
  file.absent
