include:
  - lxd

dnsloopdetect:
  cmd.run:
    - name: lxc network set lxdbr0 raw.dnsmasq "auth-zone=lxd\ndns-loop-detect"
    - require:
      - sls: lxd.lxd

dnsresolve:        
  cmd.wait:
    - name: "systemd-resolve --interface lxdbr0 --set-dns 10.117.168.1 --set-domain lxd"
    - require:
      - sls: lxd.lxd
