base:
    'netplan:static:true':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
    'salt':
      - libvirt
    'vmhost':
      - zpool
      - lxc
      - nft
      - telegraf
      - libvirt
      - libvirt.focal-img
    'influxdb':
      - influxdb
    'dns':
      - dnsmasq
    'docker':
      - docker
      - telegraf
      - keycloak.dockerized
      - grafana.dockerized
      - nginx.dockerized
    'postgresql':
      - postgresql
    'redis':
      - redis
