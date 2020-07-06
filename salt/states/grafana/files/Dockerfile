FROM grafana/grafana:7.0.5
USER root
RUN apk --no-cache add ca-certificates
WORKDIR /usr/local/share/ca-certificates
ADD development.crt /usr/local/share/ca-certificates/development.crt
RUN /usr/sbin/update-ca-certificates
USER grafana
WORKDIR /usr/share/grafana