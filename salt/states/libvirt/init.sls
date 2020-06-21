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

'virsh pool-define-as guest_images dir - - - - "/opt/libvirt_images"':
  cmd.run:
    - unless: 'virsh pool-info guest_images'

'virsh pool-build guest_images':
  cmd.run:
    - creates: /opt/libvirt_images

'virsh pool-start guest_images':
  cmd.run:
    - unless: 'virsh pool-info guest_images | grep running'
    - require:
        - cmd: 'virsh pool-build guest_images'

'virsh pool-autostart guest_images':
  cmd.run:
    - unless: 'virsh pool-info guest_images | grep "Autostart: *yes"'
