# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

/tmp/cloudinit.yaml:
  file.managed:
    - source: salt://libvirt/files/cloudinit.yaml
    - user: root
    - group: root
    - mode: 644

cloud-image-utils:
  pkg.installed

'cloud-localds -d qcow2 /opt/libvirt_images/cloudinit.img /tmp/cloudinit.yaml && virsh pool-refresh guest_images':
  cmd.wait:
    - watch:
       - file: /tmp/cloudinit.yaml
    - require:
       - pkg: cloud-image-utils
