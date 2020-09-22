# GreenWeb Documentation

## Computers

### LXM Host

A single virtual machine from the upstream provider, bootstrapped by a
masterless salt-minion to host LXC.

Security:

 - Lock down to passwordless keyed noroot ssh on a non-standard port
   plus yubikey.  Possibly port knocking. Possibly some kind of rotation.
 - Setup firewall so that only
   - INBOUND SSH to this computer
   - INBOUND SSH to salt master.
   - INBOUND SMTP (and other email protocols) to mailu
   - INBOUND HTTP to an nginx reverse container.
   - OUTBOUND http, https, ICMP and the mail stuff.
 - LXC security:
   - Containers are run as a non-root user account.
   - Containers are unprivileged -- that means their internal root account
     does not map to the system root account.
   - Some containers will use Cgroups and Ulimts. Mainly mailu and any web app
     that allows uploads to prevent too much consumption of the limited disk space.
	 I don't think I'll limit CPU and/or memory usage.
 - Logging:
   - Setup rsyslog
     - Forward system log
	 - Salt logs
	 - Rejected IP table logs, a few per second:
	   https://www.linuxquestions.org/questions/linux-security-4/iptables-logging-385165/
	 - Do I want to send to papertrail?  Probably easiest. They have
	   a free account: https://www.papertrail.com/plans/
 - After bootstrapping, it joins the saltmaster LXC and the local salt files are deleted.

Recovery:
 - There is no data on this instance.
 - If I lose my key, I can contact the upstream host to change my sshd
   config and password and let me back in.
   
Monitoring:
 - iptables
 - mem
 - net
 - processes?
 - swap
 - filestat on the ssh keys and allowed hosts.
 - disk
 - diskio
 - cpu
 - cgroup

Scaling:
 - Pay the upstream host more for a larger box. We should be able to
   scale on one VM for a while.
 - Next, start taking the most intensive applications, and move them
   to their own VM.
 - IF we continue to scale, eventually this machine disappears and we
   use 1 VM per service rather than this LXC container host.

### saltmaster

Currently an LXC container on the virtual machine.

It will have the salt repository inside it. It normally updates it
through git, which will be triggered manually.

Security:
 - Is a non-priviledged LXC container.
 - Don't bother with openssh. Use the main host as a bastion and anyone with access to
   salt can easily access anything else.
 - IP Tables configured to ONLY allow (for incoming) the salt-incoming port and the SSH.

Logging
 - Setup rsyslog with system logs, salt logs, rejected IP table logs, a few per second.
 
Monitoring
 - Configure telegraf with rsyslog to also capture salt master actions into the monitoring
   framework. Basically, I just want to know when the highstate ran.
 - filestat on the git repo

Recovery:
 - There is nothing permanent here. The salt scripts are in a git repo, and
   the salt connection keys can be regenerated.
 - If I lose this, I can instantiate a new one.

Scaling:
 - If required, I can use salt-syndic of multiple salt masters.
 
### InfluxDB

For storing the metrics.  Directly installed on LXC.

Security:
 - Unpriviledged LXC container
 - No openSSH
 - IP Tables to only allow access to the database
   - NOT exported to the public internet.

Monitoring: 
 - Size of influxdb database
 - CPU usage of the process.

Scaling:
 - None -- it's for my use only.
 
Recovery:
 - None, this data is only valid for a short time period.

### Grafana

For displaying the influxdb metrics. Directly installed on an LXC Configured by saltstack.

Security:
 - Unpriviledged LXC container
 - No openSSH
 - IP Tables to only HTTP access to the application.

Monitoring: 
 - CPU usage of the process.

Scaling:
 - None -- it's for my use only.
 
Recovery:
 - None, no data is stored here. Configuration by saltstack.

### Postgresql

Currently, LXC containers on the main host machine. Postgresql is
directly installed.

Security:
 - It is a non-priviledged LXC container.
 - No openSSH
 - IP Tables to only allow incoming/outgoing database stuff.
   - NOT exported by the bastion to the public internet.

Logging
 - Setup with rsyslog.
 
Monitoring
 - Database size
 - Database statistics
 - filestat on the postgresql configuration files
   
Scaling:
 - None, it's a single point of failure.
   In future, pg-pool looks promising, but a more realistic
   would be to purchase postgresql as a service and only use this LXC version
   in the dev environment.
   
Recovery:
 - Cold standby machine. New cold standbys can be spawned.
 - NEED A BACKUP solution.

Upgrade Procedure
 - I think I can snapshot the database and spawn a new instance to test
   out the upgrade.

### keycloak 1 and 2

Currently LXC containers on the main host machine.  Keycloak is directly
installed, it's not run in a dockerized container.  In this mode, the
drawbacks of configuration are ameloriated by salt which configures
both identically.

Security:
 - It is a non-priviledged LXC container.
 - No openSSH
 - IP Tables to only allow incoming/outgoing HTTP
   - NOT exported by the bastion to the public internet.

Logging
 - Setup with rsyslog.

Scaling:
 - If required, spawn more.
 
Monitoring
 - filestat on the configuration files
 - Telegraf parse logs: https://tech.aabouzaid.com/2019/02/monitor-keycloak-tick-prometheus.html
   to report keycloak events

Recovery:
 - Clustered, all data is in postgresql.

Dependencies:
 - Depends on postgresql

### Nginx

The nginx LXC container runs on the main host and provides a reverse
proxy to all other services and manages the SSL.

Security:
 - It is a non-priviledged LXC container.
 - No openSSH
 - IP Tables to only allow incoming/outgoing HTTP
   - NOT exported by the bastion to the public internet.

Logging
 - Setup with rsyslog.

Scaling:
 - If required, spawn more. This needs some figuring out as I think you need
   to start doing Round Robin or something.

Monitoring
 - filestat on the configuration files
 - Telegraf parse logs: https://tech.aabouzaid.com/2019/02/monitor-keycloak-tick-prometheus.html
   to report keycloak events

Recovery:
 - Nothing, no state here.

Dependencies:
 - Depends on nothing really.
