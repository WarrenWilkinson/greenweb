# Ensure nginx is installed on Nginx.
# Ensure influxdb in installed
# Ensure grafana is installed.
# Combine all three.


prep_servers:
  salt.state:
    - tgt: 'nginx,influxdb,grafana'
    - tgt_type: list
    - highstate: True 

