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
salt/pillar/demo/ demonstrate what and how passwords are specified for
different components.

You can just copy the files in the salt/pillar/demo directory into
the salt/pillar/prod directory and update the passwords, but for extra security, `encrypt the passwords within the files themselves <https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html>`_.

Encryption prevents your passwords from being read by anyone who has
access to your git repository.  It's a pain in the ass, but you only
have to do it once.

.. code-block:: console

   user@host:~/$ gpg --full-generate-key
   user@host:~/$ gpg --list-keys
   user@host:~/$ cd ~/greenweb/dev/
   user@host:greenweb/dev/$ gpg --armor --export-secret-key <KEY-NAME> > exported_greenweb_privkey.gpg
   user@host:greenweb/dev/$ gpg --armor --export <KEY-NAME> > exported_greenweb_pubkey.gpg

The :code:`<KEY-NAME>` name was printed when you ran :code:`gpg
--list-keys`. It resembles `E6FC8A182A156E9E16209DE6C6CF6DC6DDCB8906`.
Those commands put your keys into your greenweb repos dev/ folder (and
a .gitignore rule prevents accidentally committing .gpg files in
there). You should backup your public and private keys to a safe place.

With the public key you can encrypt a password:

.. code-block:: console

   user@host:~/$ echo -n "supersecret" | gpg --armor --batch --trust-model always --encrypt -r <KEY-NAME>
   
   # Or on another computer, first import the public key
   user@othercomputer:~/$ gpg --import exported_greenweb_pubkey.gpg
   user@othercomputer:~/$ echo -n "supersecret" | gpg --armor --batch --trust-model always --encrypt -r <KEY-NAME>

Now that you can encrypt passwords, here is how you'd update Grafana's
administration-user's password:

.. code-block:: console

   user@host:~/$ cd greenweb/salt/pillar
   user@host:greenweb/salt/pillar/$ cp demo/grafana.sls prod/grafana.sls
   user@host:greenweb/salt/pillar/$ nano prod/grafana.sls

Replace the plain text passwords with the GPG encrypted ones.  My
final file looks like this. Just try to guess those passwords!

.. code-block:: yaml

   #!yaml|gpg -*- coding: utf-8; mode: yaml -*-
   # vim: ft=yaml
   ---
   
   grafana:
     admin:
       user: admin
       password: |
         -----BEGIN PGP MESSAGE-----
             
         hQGMA7efR1oP+rbXAQwAibaRBOtJyPlVhpaGw48ceukXQlEQGLE07v7qzKCbR4+n
         j7uYAOxFUmndPkudUgbvFo3CWw/N/XLKm2aK7PqdFeoa8xrhMqEaFI9+ZZhI7W4r
         eu81XN6MCYKEgLTrAUs1bzef+Qk/wJ+WtEdPw8JfOAIelBT7DyM8TqRCzbx7VMyv
         Lgw9yUnsu1iMkZ5GgmoLxhqMy9dsgjCqVkPNbk9yaN434++/Rh6ycsj/uAxiIXBS
         5m5f2GF8KrKjEFAe6nr8tr0zpN1YQ9aZpgtMHG9vGopDR3HWlPlDDFmRxaLGxn7z
         xTSMOdxWTwuSWAFY6t7pXIVCCY7RF2sm+bUnWdgVTR7STPGTV72UxFpfWEkASKzr
         NOXBq1ZY8+WHGALvFZTrz1REIQOVHQkGbms5AJAReuO0mNR+jYKMu+QLaamxz8qq
         /L4hsdoMAZ61Ilkkhn9rL+fITgqBeaqLuvXQWDIsosGArXQTKdGDWCHWrPVIWppJ
         Ha2DtMOv2qNeYFbqzyi50lMBlHFOMYGMBfcXftsssMy35pNi9hp3NeueSkNb2oUL
         aaVbeq0BNhhAzSMlGZntYk9izVToT+aYiC5OuL7BBETjUVrrBqVEnMUU4j2FlOws
         eKQHIA==
         =dU+p
         -----END PGP MESSAGE-----
     secret_key: |
       -----BEGIN PGP MESSAGE-----
   
       hQGMA7efR1oP+rbXAQv/bL0DBrdUT/VJJCIGJ/CCzI2MiMyOnO/gr1E1uEuYaJs0
       wegpRhVRKdhx+OcoIAxRbA238+4OzOxZmQkIPkyQtFCqcarAbzyg/bBHEnViz9Ct
       /DHF+peT9jaRLMTIQm7yZ6MUvxOtlPe+NnjL+rYY5+jclOd7Km20FNNw3nACqRdK
       xS3b3z1pgN0wmFTV8hGYBx0YJeLPMUjhCLxwWLcXUjUs2U8bNyS/7rcrGYNSxHwc
       RD2xM7wC0EeEe5VkHBvlpxSWi08yQrPg5xV4Ia5AaUhFPdkhcwwfWHsKqaBrUMdi
       nB13GHoNk4WrP3+NpRZ3dEBCsbobQcHAHdLvVnwZprBfx+Lol3Sk/b0mbh0+1ThQ
       p+s1AAPmHAjaQMzXqTaXAE0JIn3kKuoWSpoXfEzu6fl5en9PxspAJdx02i9ZMfCQ
       juP1hYmQKfIYQ68p3X19BapX91YetEGIABpXpZHw+tgjnmsWEnUqLV0t/oMqzQ3V
       ekGPR8+xVXvoHhKOD6Zy0lMBL8dTt8YzylNZcsAg5TSvAWJEttytlRZkuz7die2I
       tNAOcGBtyJl92lQ/4B8s5L6nYh4Mb6CfNSDKVxsMygJ8FlWghxYqAq0I4CKSZVGB
       fIVq8A==
       =n9W1
       -----END PGP MESSAGE-----
   
