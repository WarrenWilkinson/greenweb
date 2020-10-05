Mile High view of the Greenweb Architecture
===========================================

Out of the box, the GreenWeb provisions a vmhost with infrastructure
software, lxc virtual machines and a libvirt virtual machine (docker).

vmhost
  Contains an openvswitch network bridge and a nft firewall. Serves as a 'bastion'
  server. Also has a salt-minion connected to the salt master. It also has a telegraf
  agent reporting metrics to influxdb.

dns
  A lxc virtual machine to host the dnsmasq software and manage DNS names on the
  openvswitch network.

salt
  A lxc virtual machine to be a salt master.

logging
  A lxc virtual machine to host rsyslog and receive logging messages. Unifies logging.

postgresql
  An lxc virtual machine to host postgresql database.  It contains database for
  orm-hydra, phpbb and drupal.

influxdb
  An lxc virtual machine to host influxdb database.

ldap
  An lxc virtual machine to host the ldap database.

postfix
  An lxc virtual machine to serve as email infrastructure. It contains postfix and
  dovecot. It is integrated into ldap.

docker
  A libvirt virtual machine (i.e. more isolated) that runs most of the front end services:

  hydra:
    orm-hydra provides oauth2 support for drupal, phpbb and grafana.

  werther:
    A login manager, integrated into hydra and ldap.

  grafana:
    A data visualization package, integrates with influxdb.

  phpbb:
    Web forum software, relies on a postgresql database and postfix emailing infrastructure.

  drupal:
    Web site software, relies on a postgresql database and postfix emailing infrastructure.

.. uml::
   :alt: Mile High Architecture Diagram
   :caption: Mile High Green Web Architecture Diagram

   left to right direction

   () internet

   skinparam component {
      FontSize 13
      BackgroundColor<<salt>> LightBlue
      BorderColor<<salt>> #Blue
      BackgroundColor<<rsyslog>> LightGray
      BorderColor<<rsyslog>> #Gray
      BackgroundColor<<telegraf>> LightPink
      BorderColor<<telegraf>> #Pink
      FontName Courier
      BorderColor black
      BackgroundColor gold
   }

   cloud "vmhost" {
      [nft]
      [openvswitch]
      [minion] <<salt>> as sm

      [openvswitch] --> salt
      [openvswitch] --> dns
      [openvswitch] --> logging
      [openvswitch] --> postgresql
      [openvswitch] --> influxdb
      [openvswitch] --> ldap
      [openvswitch] --> postfix
      [openvswitch] --> docker

      [telegraf] <<telegraf>> as vmhost_telegraf

      node "salt" {
	 [minion] <<salt>> as salt_sm
	 [master] <<salt>> as salt_master
	 salt_sm <-[#LightBlue]- salt_master
      }
      [salt_master] -[#LightBlue]-> sm
      node "dns" {
         [minion] <<salt>> as dns_sm
	 [salt_master] -[#LightBlue]-> dns_sm
      }
      node "logging" {
         [minion] <<salt>> as logging_sm
	 [salt_master] -[#LightBlue]-> logging_sm
         [rsyslog] <<rsyslog>> as logging_rsyslog
      }
      node "postgresql" {
         [minion] <<salt>> as postgresql_sm
	 [salt_master] -[#LightBlue]-> postgresql_sm
	 package "postgresql server" {
	     database "hydra" as pg_hydra {
	     }
	     database "phpbb" as pg_phpbb {
	     }
	     database "drupal" as pg_drupal {
	     }
	 }
      }
      node "ldap" {
         [minion] <<salt>> as ldap_sm
	 [salt_master] -[#LightBlue]-> ldap_sm
	 package "openldap server" {
	     database "ca.greenweb" as ldap_greenweb {
	     }
	 }
      }
      node "postfix" {
         [minion] <<salt>> as postfix_sm
	 [salt_master] -[#LightBlue]-> postfix_sm
      }
      cloud "docker" {
         [minion] <<salt>> as docker_sm
         [salt_master] -[#LightBlue]-> docker_sm
	 [telegraf] <<telegraf>> as docker_telegraf
         frame "grafana" {
	 }
         frame "nginx" {
	 }
	 frame "werther" {
	 }
         ldap_greenweb <-- werther
	 frame "hydra" {
	 }
	 frame "phpbb" {
	 }
	 frame "drupal" {
	 }

	 nginx -[#LightGreen]-> drupal
	 nginx -[#LightGreen]-> phpbb
	 nginx -[#LightGreen]-> hydra
	 nginx -[#LightGreen]-> grafana
	 nginx -[#LightGreen]-> werther
      }

      node "influxdb" {
         [minion] <<salt>> as influxdb_sm
	 [salt_master] -[#LightBlue]-> influxdb_sm
	 package "influxdb server" {
	     database "telegraf" as influx_telegraf {
	     }
	     [docker_telegraf] -[#Pink]-> influx_telegraf
	     [vmhost_telegraf] -[#Pink]-> influx_telegraf
	 }
      }

      [nft] --> [openvswitch]
      influx_telegraf <-- grafana
      pg_phpbb <-[#Orange]- phpbb
      pg_hydra <-[#Orange]- hydra
      pg_drupal <-[#Orange]- drupal

      dns        -[#Gray]-> [logging_rsyslog]
      postgresql -[#Gray]-> [logging_rsyslog]
      influxdb   -[#Gray]-> [logging_rsyslog]
      ldap       -[#Gray]-> [logging_rsyslog]
      postfix    -[#Gray]-> [logging_rsyslog]
      docker     -[#Gray]-> [logging_rsyslog]
   }

   [internet] --> [nft]
