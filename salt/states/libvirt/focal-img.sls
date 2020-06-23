# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---
include:
  - libvirt.cloudinit-img

focal-img:
  file.managed:
    # I put the '*' in front of the name to match how it's listed in the SHA256SUMS.
    - name: /opt/libvirt_images/*focal-server-cloudimg-amd64.img
    - source: https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
    - source_hash: https://cloud-images.ubuntu.com/focal/current/SHA256SUMS
    - user: root
    - group: root
    - mode: 755

'virsh pool-refresh guest_images':
  cmd.wait:
    - watch:
        - file: /opt/libvirt_images/*focal-server-cloudimg-amd64.img

focal-definition:
  file.managed:
    - name: /tmp/base-focal-64.xml
    - source: salt://libvirt/files/base-focal-64.xml
    - user: root
    - group: root
    - mode: 755

'virsh undefine base-focal-64':
  cmd.wait:
    - watch:
        - file: /tmp/base-focal-64.xml
    - unless: '! virsh dumpxml base-focal-64'

'virsh define /tmp/base-focal-64.xml':
  cmd.run:
    - unless: 'virsh dumpxml base-focal-64'
