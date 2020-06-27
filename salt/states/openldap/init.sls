# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

openldap:
  pkg.installed:
    - pkgs:
      - slapd
      - ldap-utils
  service.running:
    - name: slapd
    - enable: True

python3-ldap:
  pkg.installed

# Because this runs locally as root, then via SASL I should have write
# access to the database and be able to change the password:

root_account:
  ldap.managed:
    - connect_spec:
        url: ldapi:///
        bind:
          method: sasl
    - entries:
      - 'olcDatabase={1}mdb,cn=config':
        - replace:
            olcRootDN:
              - cn=admin,dc=greenweb,dc=ca
            olcSuffix:
              - dc=greenweb,dc=ca
            olcRootPW:
              - {{ pillar['ldap']['admin']['password'] }}

# But in the actual database, I need to use the password to
# make modifications

base_domain:
  ldap.managed:
    - connect_spec:
        url: ldapi:///
        bind:
          method: simple
          dn: cn=admin,dc=greenweb,dc=ca
          password: {{ pillar['ldap']['admin']['password'] }}
    - entries:
      - dc=greenweb,dc=ca:
        - default:
            dc: greenweb
            o: greenweb
            objectClass:
              - dcObject
              - organization
      - cn=admin,dc=greenweb,dc=ca:
        - default:
            cn: admin
            objectClass:
              - organizationalRole
