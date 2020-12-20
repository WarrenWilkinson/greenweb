FROM grafana/grafana:7.0.5
USER root
RUN apk --no-cache add ca-certificates
WORKDIR /usr/local/share/ca-certificates
ADD pebble.ca-root.crt /usr/local/share/ca-certificates/pebble.crt
RUN /usr/sbin/update-ca-certificates
USER grafana
WORKDIR /usr/share/grafana
