base:
    '*':
      - rsyslog
    'vagrant.vm':
      - zpool
      - lxc
    'nginx':
      - nginx
      - telegraf
    'influxdb':
      - influxdb
    'grafana':
      - grafana
