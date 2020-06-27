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
    'ldap':
      - openldap
    'influxdb':
      - influxdb
    'dns':
      - dnsmasq
    'docker':
      - docker
      - telegraf
      - grafana.dockerized
      - nginx.dockerized
    'postgresql':
      - postgresql
    'redis':
      - redis
