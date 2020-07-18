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
# access to the database and be able to change the password. But
# later, in using the database, I use a DN and password to make
# modifications

root_account:
  ldap.managed:
    - connect_spec:
        url: ldapi:///
        bind:
          method: sasl
    - entries:
      - olcDatabase={1}mdb,cn=config:
        - replace:
            olcRootDN:
              - cn=admin,dc=greenweb,dc=ca
            olcSuffix:
              - dc=greenweb,dc=ca
            olcRootPW:
              - {{ pillar['ldap']['admin']['password'] }}

# Note:
#
# People:
# people belong to ou=people,o=greenweb, not to their respective
# organizations. Why? Because people aren't employees, but volunteers
# who work across groups frequently.
#
# Email:
#
# A person doesn't automatically get an email address just because they're a person
# in the database.
#
# Private Mailboxes:
# To get a private email, there must be an applicationProcess in an "ou: email" organization
# with a seeAlso that points to that user. So an email for joe@ilikebike.ca would look like this:
#
# cn=joe@ilikebike.ca,dc=greenweb,dc=ca
#  ou=email
#  seeAlso: uid=joesmoe,ou=people,dc=greenweb,dc=ca
#  userpassword: thepasswordforthisprivatemailbox
#  objectClass: applicationProcess
#  objectClass: simpleSecurityObject
#
# Users log in with their email account name, not their username.  This is because a user might
# have multiple private mailboxes, if they're a member of multiple different organizations.
#
# Aliased Mailboxes:
# We also support mail aliases.  This is an email address that seeAlso's another
# mail address.
#
# cn=postmaster@greenweb.ca,ou=email,dc=greenweb,dc=ca
#  ou=email
#  seeAlso: cn=warren@greenweb.ca,ou=email,dc=greenweb,dc=ca
#  objectClass: applicationProcess
#
# Public Mailboxes:
# A public mailbod is something like contact@ilikebike.ca whose
# mailbox appears as a public subfolder so that people (logged in as a
# different mailbox) have access to it and can respond to emails
# therein.
#
# cn=contact@ilikebike.ca,ou=email,dc=greenweb,dc=ca
#  ou=email
#  Member: joe@ilikebike.ca,ou=email,dc=greenweb,dc=ca
#  Member: jane@ilikebike.ca,ou=email,dc=greenweb,dc=ca
#  objectClass: groupOfUniqueNames

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
      - ou=apps,dc=greenweb,dc=ca:
        - default:
            ou: apps
            objectClass:
              - organizationalUnit
      - cn=dovecot,ou=apps,dc=greenweb,dc=ca:
        - default:
            cn: dovecot
            ou: apps
            objectClass:
              - applicationProcess
              - simpleSecurityObject
        - replace:
            userPassword:
              - {{ pillar['dovecot']['ldap']['password'] }}
      - cn=postfix,ou=apps,dc=greenweb,dc=ca:
        - default:
            cn: postfix
            ou: apps
            objectClass:
              - applicationProcess
              - simpleSecurityObject
        - replace:
            userPassword:
              - {{ pillar['postfix']['ldap']['password'] }}
      - ou=people,dc=greenweb,dc=ca:
        - default:
            ou: people
            objectClass:
              - organizationalUnit
      - uid=wwilkinson,ou=people,dc=greenweb,dc=ca:
        - default:
            cn: Warren
            sn: Wilkinson
            uid: wwilkinson
            userPassword: []
            objectClass:
              - inetOrgPerson
      - ou=email,dc=greenweb,dc=ca:
        - default:
            ou: email
            objectClass:
              - organizationalUnit
      - cn=warren@greenweb.ca,ou=email,dc=greenweb,dc=ca:
        - default:
            cn: warren@greenweb.ca
            ou: email
            seeAlso: uid=wwilkinson,ou=people,dc=greenweb,dc=ca
            userPassword: []
            objectClass:
              - applicationProcess
              - simpleSecurityObject
      - cn=postmaster@greenweb.ca,ou=email,dc=greenweb,dc=ca:
        - default:
            cn: postmaster@greenweb.ca
            ou: email
            seeAlso: cn=warren@greenweb.ca,ou=email,dc=greenweb,dc=ca
            objectClass:
              - applicationProcess
      - cn=contact@greenweb.ca,ou=email,dc=greenweb,dc=ca:
        - default:
            cn: contact@greenweb.ca
            ou: email
            userPassword: []
            member:
              - cn=warren@greenweb.ca,ou=email,dc=greenweb,dc=ca
            objectClass:
              - groupOfNames
              - simpleSecurityObject

# Very locked down. I tend to use this logged into the computer by the root dn and
# I'm not exporting ldap information as a service.  Ergo, lock it down hard.
# The original permissions were:
#olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * none
#olcAccess: {1}to attrs=shadowLastChange by self write by * read
#olcAccess: {2}to * by * read

# 0. Dovecot can read everything related to emails, including email passwords. Must be subtree, not children.
# 1. Users can update, but not read password. Anonymous can auth against a password. Everyone else has no access to userPasswords.
# 2. Postfix is like dovecot, but doesn't see passwords.
# 3. You can read/write your own entry (but not read password), otherwise no access.

security:
  ldap.managed:
    - connect_spec:
        url: ldapi:///
        bind:
          method: sasl
    - entries:
      - olcDatabase={1}mdb,cn=config:
        - replace:
            olcAccess:
              - to dn.subtree="ou=email,dc=greenweb,dc=ca" attrs=userPassword by dn.base="cn=dovecot,ou=apps,dc=greenweb,dc=ca" read by * none
              - to attrs=userPassword by self =xw by anonymous auth by * none
              - to dn.subtree="ou=email,dc=greenweb,dc=ca" by dn.base="cn=postfix,ou=apps,dc=greenweb,dc=ca" read by dn.base="cn=dovecot,ou=apps,dc=greenweb,dc=ca" read by * none
              - to * by self write by * none
