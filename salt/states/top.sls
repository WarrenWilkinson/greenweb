base:
    'netplan:static:true':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
    'salt':
      - libvirt
      - libvirt.bionic-img
    'vagrant.vm':
      - zpool
      - lxc
      - nft
      - telegraf
      - libvirt
    'nginx':
      - nginx
      - telegraf
    'influxdb':
      - influxdb
    'grafana':
      - grafana
    'dns':
      - dnsmasq
    'kubernetes':
      - kubernetes
    'postgresql':
      - postgresql
    'keycloak':
      - keycloak
    'redis':
      - redis
