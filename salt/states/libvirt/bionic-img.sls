# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

bionic-img:
  file.managed:
    # I put the '*' in front of the name to match how it's listed in the SHA256SUMS.
    - name: /opt/libvirt_images/*bionic-server-cloudimg-amd64.img
    - source: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
    - source_hash: https://cloud-images.ubuntu.com/bionic/current/SHA256SUMS
    - user: root
    - group: root
    - mode: 755

'virsh pool-refresh guest_images':
  cmd.wait:
    - watch:
        - file: /opt/libvirt_images/*bionic-server-cloudimg-amd64.img

bionic-definition:
  file.managed:
    - name: /tmp/base-bionic-64.xml
    - source: salt://libvirt/files/base-bionic-64.xml
    - user: root
    - group: root
    - mode: 755

'virsh define /tmp/base-bionic-64.xml':
  cmd.run:
    - unless: 'virsh dumpxml base-bionic-64'
