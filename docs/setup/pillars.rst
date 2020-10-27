Changing Passwords
==================

You make greenweb your own by changing the locks. And the "locks" are
passwords, credentials, and private keys.

Greenweb uses `Salt <https://docs.saltstack.com/en/latest/>`_, (a tool
that installs software and configures systems) to setup passwords. To
change a password, let Salt update it; Just put the updated password
in the `Salt Pillar
<https://docs.saltstack.com/en/getstarted/config/pillar.html>`_.

Production passwords are stored in the salt/pillar/prod/ directory,
and on a fresh checkout it's mostly empty.  The files in
salt/pillar/demo/ demonstrate what how passwords are specified for
different components.

You could just copy the files in the salt/pillar/demo directory into
the salt/pillar/prod directory. Just make sure you change the
passwords and, for extra security, `encrypt the passwords within the files themselves <https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html>`_.

The extra encryption prevents others with access to your git
repository from reading the plain text passwords and accessing your
system.
