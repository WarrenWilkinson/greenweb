# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---


bionic-img:
  file.managed:
    # I put the '*' in front of the name to match how it's listed in the SHA256SUMS.
    - name: /opt/*bionic-server-cloudimg-amd64.img
    - source: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
    - source_hash: https://cloud-images.ubuntu.com/bionic/current/SHA256SUMS    
    - user: root
    - group: root
    - mode: 755  

# virsh define bionic... need xml file?