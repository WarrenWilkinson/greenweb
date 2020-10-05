Building the Documentation
==========================

You'll need to install `Sphinx <https://www.sphinx-doc.org/en/master/usage/installation.html>`_, and several
plugins/themes. If you're running a recent ubuntu/debian, these commands should do it:

.. code-block:: console

   user@host:~/$ sudo apt-get upgrade
   user@host:~/$ sudo apt-get install python3-sphinx python3-sphinx-rtd-theme python3-sphinxcontrib.plantuml

Once these are installed, the documentation can be built from the docs
directory. The resulting html files are placed in docs/_build.

.. code-block:: console

   user@host:~/greenweb/docs/$ make html

