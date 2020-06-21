# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

libvirt:
  pkg.installed:
    - pkgs:
      - python-libvirt
      - qemu-kvm
      - libvirt-daemon-system
#      - libvirt-clients
#   # Disabled the below, which makes it listen on TCP... do I want that?
#   # file.managed:
#   #   - name: /etc/default/libvirtd
#   #   - contents: 'LIBVIRTD_ARGS="--listen"'
#   #   - require:
#   #     - pkg: libvirt
#   virt.keys:
#     - require:
#       - pkg: libvirt
  service.running:
    - name: libvirtd
    - require:
      - pkg: libvirt
#     #    - network: br0
#     #    - libvirt: libvirt
#     # - watch:
#     #   - file: libvirt

# python-libvirt:
#   pkg.installed

# libguestfs:
#   pkg.installed:
#     - pkgs:
#       - libguestfs
#       - libguestfs-tools
