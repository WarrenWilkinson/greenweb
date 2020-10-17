Changing Passwords
==================

You make greenweb your own by changing the locks. And the "locks" are
passwords, credentials, and private keys.

Greenweb uses `Salt <https://docs.saltstack.com/en/latest/>`_, (a tool
that updates systems based on programmatic rules) to mainatin
appropriate locks. So, to change a password, you need to tell Salt
what the new password so it can apply it. And you tell Salt the new
password by providing it in the `Salt Pillar
<https://docs.saltstack.com/en/getstarted/config/pillar.html>`_.

You do that by editing the text files inside the salt/pillar directory...
