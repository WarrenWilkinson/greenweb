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
earlier</cantrips/runit>` so that they point to your new name

Certificates
--------------

During development, greenweb spawns an `internal pebble server
<https://github.com/letsencrypt/pebble>`_ and uses that with certbot
to get certificates for SSL (that's why your browser keeps complaining
about untrusted keys).

In production, make sure you don't use the pebble server. That's
controlled in the configuration.yaml file.

The servers are requested by the Docker virtual machine, as part of
`setting up nginx <https://github.com/WarrenWilkinson/greenweb/blob/master/salt/states/nginx/dockerized.sls>`_.
So if you're running more virtual hosts, you'll want to modify that
file.

Finally, postfix also requests a certificate
`postfix also requests a certificate <https://github.com/WarrenWilkinson/greenweb/blob/master/salt/states/postfix/init.sls>`_.
