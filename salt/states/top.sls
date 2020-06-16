base:
    'netplan:static:true':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
    'vagrant.vm':
      - zpool
      - lxc
      - nft
      - telegraf
    'nginx':
      - nginx
      - telegraf
    'influxdb':
      - influxdb
    'grafana':
      - grafana
    'dns':
      - dnsmasq
    'postgresql':
      - postgresql
    'keycloak':
      - keycloak
    'redis':
      - redis
