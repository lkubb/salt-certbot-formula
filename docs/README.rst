.. _readme:

certbot Formula
===============

|img_sr| |img_pc|

.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

Manage certbot with Salt.

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------


Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.


Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``certbot``
^^^^^^^^^^^
*Meta-state*.

This installs the certbot package,
manages the certbot configuration file
and then enables the certbot autorenew timer.
Also manages issued certificates,
possibly OCSP fetcher and certsync setup.


``certbot.package``
^^^^^^^^^^^^^^^^^^^
Installs the certbot package only.


``certbot.config``
^^^^^^^^^^^^^^^^^^
Manages the certbot service configuration.
Has a dependency on `certbot.package`_.


``certbot.service``
^^^^^^^^^^^^^^^^^^^
Enables the certbot autorenew timer.
Has a dependency on `certbot.config`_.


``certbot.certs``
^^^^^^^^^^^^^^^^^
Ensures configured certificates are present.


``certbot.ocsp_fetcher``
^^^^^^^^^^^^^^^^^^^^^^^^
Installs ``certbot-ocsp-fetcher`` + service/timer and enables it.


``certbot.ocsp_fetcher.package``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Installs ``certbot-ocsp-fetcher`` + service/timer unit files.


``certbot.ocsp_fetcher.service``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Enables the ``certbot-ocsp-fetcher`` timer.


``certbot.certsync``
^^^^^^^^^^^^^^^^^^^^
Installs ``rsync`` and configures a dedicated user account
intended to be used to sync LE certificates to hosts behind
a DMZ. Certificates are regularly synced to subdirectories
in this user's home directory. Downstream hosts can submit
public keys, which will be given very restricted access to
the associated directory only (using ``rrsync``).

Needs to be targeted to the server accessible from the
public internet.


``certbot.certsync.config``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Manages ``authorized_keys`` configuration for the certsync user.


``certbot.certsync.package``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Install ``rsync``, certsync user, script and service [timer].


``certbot.certsync.service``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Ensures the certsync timer is enabled.
Syncs certificates during the first run
(specifically when ``authorized_keys`` or the certsync
script states report changes).


``certbot.sync_certs``
^^^^^^^^^^^^^^^^^^^^^^
Installs ``rsync`` + sync_cert scripts, generates SSH keys
and sends those to the mine for server registration.
Also enables a ``sync_certs`` timer and tries to synchronize
certificates from the upstream server with the ``root`` user account.

Needs to be targeted to hosts that should be able to pull LE certificates
that are not reachable from the public internet.


``certbot.sync_certs.config``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Creates an SSH private key. Needs to ensure it will be accepted
by the host to sync from, either by sending its public key to the mine
or by generating an SSH client certificate if configured.


``certbot.sync_certs.package``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Installs ``rsync`` and sync_certs service.


``certbot.sync_certs.service``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Enables the sync_certs timer and tries to synchronize
certificates once.


``certbot.clean``
^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``certbot`` meta-state
in reverse order, i.e.
removes certsync and ocsp fetcher,
removes the managed certificates and private keys,
disables the autorenew timer,
removes the configuration file and then
uninstalls the package.


``certbot.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the certbot package.
Has a dependency on `certbot.config.clean`_.


``certbot.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the certbot service and has a
dependency on `certbot.service.clean`_.


``certbot.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Disables the certbot autorenew timer.


``certbot.certs.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes managed certificates.


``certbot.ocsp_fetcher.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Disables ``certbot-ocsp-fetcher`` timer,
removes the service/timer unit files + package.


``certbot.ocsp_fetcher.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes ``certbot-ocsp-fetcher`` + service/timer unit files.


``certbot.ocsp_fetcher.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Disables the ``certbot-ocsp-fetcher`` timer.


``certbot.certsync.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Disables the certsync timer, removes configuration, scripts,
service and user.


``certbot.sync_certs.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Undoes everything `certbot.sync_certs`_ does, in particular
disables the sync_certs timer, removes SSH keys and sync_certs
service/timer unit files. Removes the borg server from known hosts.
Does *not* remove rsync.



Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.
