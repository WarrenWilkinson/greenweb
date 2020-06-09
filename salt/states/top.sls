base:
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
