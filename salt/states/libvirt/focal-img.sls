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

focal-resized-img:
  cmd.wait:
    - name: cp "*focal-server-cloudimg-amd64.img" "focal-server-cloudimg-amd64.img" && qemu-img resize focal-server-cloudimg-amd64.img +12G
    - cwd: /opt/libvirt_images/
    - watch:
        - file: /opt/libvirt_images/*focal-server-cloudimg-amd64.img
    - creates: /opt/libvirt_images/focal-server-cloudimg-amd64.img

'virsh pool-refresh guest_images':
  cmd.wait:
    - watch:
        - file: /opt/libvirt_images/*focal-server-cloudimg-amd64.img
        - cmd: focal-resized-img

focal-definition:
  file.managed:
    - name: /tmp/base-focal-64.xml
    - source: salt://libvirt/files/base-focal-64.xml.jinja
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - defaults:
        mounts:
          greenwebauth: /opt/greenwebauth

'virsh undefine base-focal-64':
  cmd.wait:
    - watch:
        - file: /tmp/base-focal-64.xml
    - unless: '! virsh dumpxml base-focal-64'

'virsh define /tmp/base-focal-64.xml':
  cmd.run:
    - unless: 'virsh dumpxml base-focal-64'
