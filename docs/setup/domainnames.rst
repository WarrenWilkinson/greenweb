Changing Domain Names
=====================

Your greenweb instance has a sort of "primary" internal domain
name. By default, it's greenweb.ca. Since you don't own that domain
name, you'll need to change it to something else.  This will have the
effect of changing all the basic URIS. For example, forum.greenweb.ca
will now be forum.yournewname.com or whatever you picked.

The internal virtual machines are given their fully qualified domain
names by a `DNSMasq <http://www.thekelleys.org.uk/dnsmasq/doc.html>`_
instance that handles DHCP on the `openvswitch
<https://www.openvswitch.org/>`_ network. All internalvirtual machines
are connected (see :doc:`architecture</developers/architecture>`) to
this network.

You can change the domain that DNSMasq assigns by editing the
`configuration settings in Salt <https://github.com/WarrenWilkinson/greenweb/blob/master/salt/states/configuration.yaml.template>`_. Just copy the provided template file and edit
it to your hearts content:

.. code-block:: console

   user@host:~/$ cd ~/greenweb/salt/states
   user@host:greenweb/salt/states/$ cp configuration.yaml.template configuration.yaml
   user@host:greenweb/salt/states/$ nano configuration.yaml

.. include:: ../../salt/states/configuration.yaml.template
  :code: yaml

Change the :code:`{% set internal_organization = 'greenweb' %}` and
:code:`{% set internal_toplevel_domain = 'ca' %}` to something
suitable. You'll need to add/change the host entries :doc:`you created
earlier</cantrips/runit>` so that they point to your new name. And
finally, you'll need to create a new certificate for SSL
communication.  The bundled, self-signed, \*.greenweb.ca certificates
won't do anything inside a network of machines named
\*.fancyfiestafriends.au.

Creating New Self Signed Certificates (For Testing)
---------------------------------------------------

The shell session below demonstrates how to create a self-signed
wildcard domain certificate for any domain you like.  They shouldn't
be used for production as no webbrowser will accept them without first
confirming with the user.

.. code-block:: console

   # Create Key Pair (mydomain.com.pair)
   user@host:~/$ cd ~/greenweb/dev
   user@host:~/greenweb/dev/$ openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out mydomain.com.pair

   # Extract private key (mydomain.com.key)
   user@host:~/$ openssl rsa -passin pass:x -in mydomain.com.pair -out mydomain.com.key

   # Create a certificate signing Request (mydomain.com.csr)
   # it will ask you some questions; Use an empty challenge password.
   user@host:~/$ openssl req -new -key mydomain.com.key -out mydomain.com.csr
   #Country Name (2 letter code) [AU]:CA
   #State or Province Name (full name) [Some-State]:British Columbia
   #Locality Name (eg, city) []:Coquitlam
   #Organization Name (eg, company) [Internet Widgits Pty Ltd]:My Domain
   #Organizational Unit Name (eg, section) []:
   #Common Name (e.g. server FQDN or YOUR name) []:*.mydomain.com
   #Email Address []:postmaster@mydomain.com
   #
   #Please enter the following 'extra' attributes
   #to be sent with your certificate request
   #A challenge password []:
   #An optional company name []:

   # Create a self-signed certificate (mydomain.com.crt)
   user@host:~/$ openssl x509 -req -days 365 -in mydomain.com.csr -signkey mydomain.com.key -out mydomain.com.crt

Just keep your self-signed keys in the greenweb/dev directory, and go
ahead and check them into source control.  The coldstart script will
copy them to where they need to be.  In production deployments, they
won't be used at all.

Getting Real Certificates (for Production)
------------------------------------------

Using CertBot (For Production)
------------------------------



