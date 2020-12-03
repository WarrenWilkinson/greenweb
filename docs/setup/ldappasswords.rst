Changing LDAP Passwords
============================

There is a script to change ldap passwords easily. Now if
only there was a script to add ldap users easily :-)

.. code-block:: console

   vagrant@vagrant$ sudo lxc-attach ldap
   root@ldap$ change-ldap-password uid=wwilkinson,ou=people,dc=greenweb,dc=ca
