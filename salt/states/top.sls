base:
    'netplan:static:true':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
    'salt':
      - libvirt
    'vagrant.vm':
      - zpool
      - lxc
      - nft
      - telegraf
      - libvirt
      - libvirt.bionic-img
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
