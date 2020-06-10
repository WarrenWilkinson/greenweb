base:
    'netplan.static:yes':
      - match: pillar
      - netplan.static
    '*':
      - rsyslog
    'vagrant.vm':
      - zpool
      - lxc
      - nft
    'nginx':
      - nginx
      - telegraf
    'influxdb':
      - influxdb
    'grafana':
      - grafana
