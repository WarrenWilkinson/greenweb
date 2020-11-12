Testing Production Passwords
============================

You can locally test greenweb with your production passwords. Which is
a good idea, if only to check that your passwords were applied.

The procedure is the same as in :doc:`launching the development
instance of greenweb</cantrips/runit>`, but run :code:`sh
/vagrant/coldstart.sh prod` instead of just :code:`sh
/vagrant/coldstart.sh`:

.. code-block:: console

   user@host:~/$ cd greenweb/dev
   user@host:greenweb/dev/$ vagrant up
   user@host:greenweb/dev/$ vagrant ssh
   vagrant@vagrant$ sh /vagrant/coldstart.sh prod

The :code:`prod` argument to coldstart.sh will ensure salt is setup to
use the production pillar data. The script will also install the gpg
keys you created in :doc:`the previous chapter</setup/pillars>` (hint:
:code:`dev/prod_pubkey.gpg` and :code:`dev/prod_privkey.gpg`) to the
correct location on the salt master.
