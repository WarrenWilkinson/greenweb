# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

{% import_yaml 'configuration.yaml' as config %}

{% set org = config.internal_organization %}
{% set domain = config.internal_domain %}
{% set tl = config.internal_toplevel_domain %}

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

# Install the postfix-book.schema
/usr/local/etc/openldap:
    file.directory:
    - user: root
    - group: root
    - mode: 755

/usr/local/etc/openldap/schema:
    file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
        - file: /usr/local/etc/openldap

/usr/local/etc/openldap/schema/postfix-book.schema:
  file.managed:
    - source: salt://openldap/files/postfix-book.schema
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: openldap
    - require:
        - file: /usr/local/etc/openldap/schema

/usr/local/etc/openldap/schema/postfix-book.ldif:
  file.managed:
    - source: salt://openldap/files/postfix-book.ldif
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: openldap
    - require:
        - file: /usr/local/etc/openldap/schema

# This command generates something like the ldif from the
# schema. It still requires manual tweaking though.
# "slaptest -f postfix-book.schema -F .":
#     cmd.wait:
#     - watch:
#         - file: /usr/local/etc/openldap/schema/postfix-book.schema
#     - cwd: /usr/local/etc/openldap/schema/

'ldapadd -Y EXTERNAL -H ldapi:// -f /usr/local/etc/openldap/schema/postfix-book.ldif':
    cmd.wait:
    - watch:
        - file: /usr/local/etc/openldap/schema/postfix-book.ldif

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
              - cn=admin,dc={{ org }},dc={{ tl }}
            olcSuffix:
              - dc={{ org }},dc={{ tl }}
            olcRootPW:
              - {{ pillar['ldap']['admin']['password'] }}
      - cn=config:
        - replace:
            olcPasswordCryptSaltFormat: $6$%.16s

##
# People:
#
# people belong to ou=people,o=greenweb, not to their respective
# organizations. Why? Because people aren't employees, but volunteers
# who work across groups frequently.  They are simpleSecurityObjects
# with passwords. If a user is expelled, delete the person.
#
# Fields to populate
#   givenName: The persons true first name
#   displayName: The persons full displayed name "nickname/truename surname" (their preference).
#   cn: The persons commonly referred to first name (e.g. the nickname)
#   sn: The persons surname
#   mail: The persons email address
#   uid: The preferred username in applications.
#   employeeNumber: "America/Vancouver" -- this field is used for a zoneinfo preferences.
#   preferredLanguage: "en-US"
#   jpegPhoto:  An optional photo

##
# Email:
#
# A person doesn't automatically get an email address just because they're a person
# in the database.
#
# Private Mailboxes:
#  Handled by having a simpleSecurityObject in the "ou: email" organization.
#  The seeAlso should point to the owner. Aliases are supported. So an email for joe@ilikebike.ca,
#  (with aliases joe@greenweb.ca joe@otherproject.ca) would look like this:
#
# cn=joe@ilikebike.ca,dc=greenweb,dc=ca
#  ou=email
#  seeAlso: uid=joesmoe,ou=people,dc=greenweb,dc=ca
#  userpassword: thepasswordforthisprivatemailbox
#  mail: joe@ilikebike.ca
#  mailAlias: joe@greenweb.ca
#  mailAlias: joe@otherproject.ca
#  objectClass: PostfixBookMailAccount
#  objectClass: applicationProcess
#  objectClass: simpleSecurityObject
#
# Users log in with their email account name, not their username,
# because users might have multiple private mailboxes.
#
# Public Mailboxes:
# A public mailbod is something like contact@ilikebike.ca whose
# mailbox appears as a public subfolder so that people (logged in as a
# different mailbox) have access to it and can respond to emails
# therein.  It looks like a mailbox withouth simpleSecurityObject (and no password).
#
# Users who are permitted to use it (e.g. joe) should have
# mailGroupMember: contact@ilkebike.ca

base_domain:
  ldap.managed:
    - connect_spec:
        url: ldapi:///
        bind:
          method: simple
          dn: cn=admin,dc={{ org }},dc={{ tl }}
          password: {{ pillar['ldap']['admin']['password'] }}
    - entries:
      - dc={{ org }},dc={{ tl }}:
        - default:
            dc: {{ org }}
            o: {{ org }}
            objectClass:
              - dcObject
              - organization
      - cn=admin,dc={{ org }},dc={{ tl }}:
        - default:
            cn: admin
            objectClass:
              - organizationalRole
      - ou=apps,dc={{ org }},dc={{ tl }}:
        - default:
            ou: apps
            objectClass:
              - organizationalUnit
      - cn=dovecot,ou=apps,dc={{ org }},dc={{ tl }}:
        - default:
            cn: dovecot
            ou: apps
            userPassword: "{CRYPT}unset."
            objectClass:
              - applicationProcess
              - simpleSecurityObject
      - cn=postfix,ou=apps,dc={{ org }},dc={{ tl }}:
        - default:
            cn: postfix
            ou: apps
            userPassword: "{CRYPT}unset."
            objectClass:
              - applicationProcess
              - simpleSecurityObject
      - cn=werther,ou=apps,dc={{ org }},dc={{ tl }}:
        - default:
            cn: werther
            ou: apps
            userPassword: "{CRYPT}unset."
            objectClass:
              - applicationProcess
              - simpleSecurityObject
      - ou=people,dc={{ org }},dc={{ tl }}:
        - default:
            ou: people
            objectClass:
              - organizationalUnit
      - uid=wwilkinson,ou=people,dc={{ org }},dc={{ tl }}:
        - default:
            givenName: Warren
            displayName: Warren Wilkinson
            cn: Warren
            sn: Wilkinson
            mail: warrenwilkinson@gmail.com
            uid: wwilkinson
            employeeNumber: "America/Vancouver"
            preferredLanguage: "en-US"
            userPassword: "{CRYPT}unset."
            objectClass:
              - inetOrgPerson
              - simpleSecurityObject
      - ou=grants,dc={{ org }},dc={{ tl }}:
        - default:
            ou: grants
            objectClass:
              - organizationalUnit
      - ou=grafana,ou=grants,dc={{ org }},dc={{ tl }}:
        - default:
            ou: grafana
            objectClass:
              - organizationalUnit
      - cn=grafana_admin,ou=grafana,ou=grants,dc={{ org }},dc={{ tl }}:
        - default:
            cn: grafana_admin
            # Group name froms from description
            description: admin
            member: uid=wwilkinson,ou=people,dc={{ org }},dc={{ tl }}
            objectClass:
              - groupofnames
      - ou=email,dc={{ org }},dc={{ tl }}:
        - default:
            ou: email
            objectClass:
              - organizationalUnit
      - cn=test@{{ domain }},ou=email,dc={{ org }},dc={{ tl }}:
        - replace:
            mailEnabled: "FALSE"
        - default:
            cn: test@{{ domain }}
            ou: email
            seeAlso: uid=wwilkinson,ou=people,dc={{ org }},dc={{ tl }}
            mail: test@{{ domain }}
            userPassword: "{CRYPT}unset."
            mailAlias:
              - testalias@{{ domain }}
            mailGroupMember:
              - testgroup@{{ domain }}
            objectClass:
              - PostfixBookMailAccount
              - simpleSecurityObject
              - applicationProcess
      - cn=quotatest@{{ domain }},ou=email,dc={{ org }},dc={{ tl }}:
        - replace:
            mailEnabled: "FALSE"
        - default:
            cn: quotatest@{{ domain }}
            ou: email
            seeAlso: uid=wwilkinson,ou=people,dc={{ org }},dc={{ tl }}
            mail: quotatest@{{ domain }}
            mailQuota: 1
            userPassword: "{CRYPT}unset."
            objectClass:
              - PostfixBookMailAccount
              - simpleSecurityObject
              - applicationProcess
      - cn=warren@{{ domain }},ou=email,dc={{ org }},dc={{ tl }}:
        - default:
            cn: warren@{{ domain }}
            ou: email
            seeAlso: uid=wwilkinson,ou=people,dc={{ org }},dc={{ tl }}
            mail: warren@{{ domain }}
            mailAlias:
              - postmaster@{{ domain }}
            mailGroupMember:
              - contact@{{ domain }}
            userPassword: "{CRYPT}unset."
            objectClass:
              - PostfixBookMailAccount
              - simpleSecurityObject
              - applicationProcess
      - cn=contact@{{ domain }},ou=email,dc={{ org }},dc={{ tl }}:
        - default:
            cn: contact@{{ domain }}
            ou: email
            mail: contact@{{ domain }}
            objectClass:
              - PostfixBookMailAccount
              - applicationProcess
      - cn=testgroup@{{ domain }},ou=email,dc={{ org }},dc={{ tl }}:
        - replace:
            mailEnabled: "FALSE"
        - default:
            cn: testgroup@{{ domain }}
            ou: email
            mail: testgroup@{{ domain }}
            objectClass:
              - PostfixBookMailAccount
              - applicationProcess

# Very locked down. I tend to use this logged into the computer by the root dn and
# I'm not exporting ldap information as a service.  Ergo, lock it down hard.
# The original permissions were:
#olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * none
#olcAccess: {1}to attrs=shadowLastChange by self write by * read
#olcAccess: {2}to * by * read

# 0. Dovecot can read everything related to emails, including email passwords. Must be subtree, not children.
# 1. Users can update, but not read password. Anonymous can auth against a password. Everyone else has no access to userPasswords.
# 2. Postfix is like dovecot, but doesn't see passwords.
# 3. Werther can search user uid to get a DN. (It then binds as that DN and should be able read attributes).
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
              - to dn.subtree="ou=email,dc={{ org }},dc={{ tl }}" attrs=userPassword by dn.base="cn=dovecot,ou=apps,dc={{ org }},dc={{ tl }}" read by * none
              - to attrs=userPassword by self =xw by anonymous auth by * none
              - to dn.subtree="ou=email,dc={{ org }},dc={{ tl }}" by dn.base="cn=postfix,ou=apps,dc={{ org }},dc={{ tl }}" read by dn.base="cn=dovecot,ou=apps,dc={{ org }},dc={{ tl }}" read by * none
              - to dn.subtree="ou=grants,dc={{ org }},dc={{ tl }}" by dn.base="cn=werther,ou=apps,dc={{ org }},dc={{ tl }}" read by * none
              - to dn.base="ou=people,dc={{ org }},dc={{ tl }}" by dn.base="cn=werther,ou=apps,dc={{ org }},dc={{ tl }}" search by * none

              # This was enough to make werther only able to read uid and type.  Werther requires access to everything due to how it's implemented.
              # - to dn.children="ou=people,dc={{ org }},dc={{ tl }}" attrs=uid,objectClass by dn.base="cn=werther,ou=apps,dc={{ org }},dc={{ tl }}" search by self read by * none
              # - to dn.children="ou=people,dc={{ org }},dc={{ tl }}" attrs=entry by dn.base="cn=werther,ou=apps,dc={{ org }},dc={{ tl }}" read by self read by * none
              # This variation should let them read everything but password.
              - to dn.children="ou=people,dc={{ org }},dc={{ tl }}" attrs=userPassword by anonymous auth by * none
              - to dn.children="ou=people,dc={{ org }},dc={{ tl }}" by dn.base="cn=werther,ou=apps,dc={{ org }},dc={{ tl }}" read by self read by * none
              - to * by self write by * none

# Set a few passwords.
# Use ldapmodify and slappassd to encode the passwords correctly. This is a bit tricky to do in fact.

# Add users like this: ('wwilkinson', 'uid=wwilkinson,ou=people,dc=' + org + ',dc=' + tl, 'wwilkinson'),

{% set lines = [] %}
{% for (file, user, password) in [ ('test', 'cn=test@' + domain + ',ou=email,dc=' + org + ',dc=' +  tl, 'test'),
                                   ('quotatest', 'cn=quotatest@' + domain + ',ou=email,dc=' + org + ',dc=' +  tl, 'quotatest'),
                                   ('dovecot', 'cn=dovecot,ou=apps,dc=' + org + ',dc=' + tl, pillar['dovecot']['ldap']['password']),
                                   ('postfix', 'cn=postfix,ou=apps,dc=' + org + ',dc=' + tl, pillar['postfix']['ldap']['password']),
                                   ('werther', 'cn=werther,ou=apps,dc=' + org + ',dc=' + tl, pillar['werther']['ldap']['password'])] %}
{{ lines.append("dn: " + user) or "" }}
{{ lines.append('changetype: modify') or "" }}
{{ lines.append('replace: userPassword') or "" }}
{{ lines.append("userPassword: include(" + file + ".password)dnl") or "" }}
{{ lines.append("__BLANK__") or "" }}
encrypt_{{ user }}_password:
  cmd.run:
    - name: slappasswd -h {CRYPT} -c '$6$%.16s' -s '{{ password }}' > "/tmp/{{ file }}.password"
{% endfor %}

/tmp/update_passwords.m4:
  file.managed:
    - contents:
        {% for line in lines %}
        - '{{ line }}'
        {% endfor %}

'm4 -I /tmp/ -D __BLANK__= /tmp/update_passwords.m4 > /tmp/update_passwords.ldif; rm /tmp/*.password /tmp/update_passwords.m4':
  cmd.run

update_passwords:
  cmd.run:
    - name: ldapmodify -x -D cn=admin,dc={{ org }},dc={{ tl }} -H ldapi:/// -w {{ pillar['ldap']['admin']['password'] }} -f /tmp/update_passwords.ldif && rm /tmp/update_passwords.ldif
