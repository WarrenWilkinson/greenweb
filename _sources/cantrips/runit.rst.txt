Running Greenweb Locally
====================================

You'll need to install `Vagrant <https://www.vagrantup.com/>`_, if
you're running a recent ubuntu/debian, these commands should do it:

.. code-block:: console

   user@host:~/$ sudo apt-get upgrade
   user@host:~/$ sudo apt-get install vagrant

Once that's done, clone the `greenweb repository <https://github.com/WarrenWilkinson/greenwebrepository>`_. Install git first if you don't have it:

.. code-block:: console

   user@host:~/$ sudo apt-get upgrade
   user@host:~/$ sudo apt-get install git
   user@host:~/$ git clone https://github.com/WarrenWilkinson/greenweb.git

Now, change into the dev directory of your newly cloned repository,
and start up the virtual machine and connect to it.

.. code-block:: console

   user@host:~/$ cd greenweb/salt/states
   user@host:greenweb/salt/states/$ cp configuration.yaml.template configuration.yaml
   user@host:greenweb/salt/states/$ cd ../../dev
   user@host:greenweb/dev/$ vagrant up
   user@host:greenweb/dev/$ vagrant ssh
   vagrant@vagrant$ sh /vagrant/coldstart.sh

This process will take an hour or so. The `coldstart.sh script
<https://github.com/WarrenWilkinson/greenweb/blob/master/dev/coldstart.sh>`_
will install `saltstack <https://docs.saltstack.com/en/latest/>`_, and
then use it to create and install all the relevant virtual machines,
networks and software.

The virtual machine will us the IP Address 172.30.1.5. Modify your
/etc/hosts file to contain this line::

   172.30.1.5             greenweb.ca forum.greenweb.ca mail.greenweb.ca identity.greenweb.ca grafana.greenweb.ca drupal.greenweb.ca

Once your virtual machine is running, and you have modified your
hosts file, you should be able to visit the various services:

* `<http://grafana.greenweb.ca>`_
* `<http://forum.greenweb.ca>`_
* `<http://drupal.greenweb.ca>`_
