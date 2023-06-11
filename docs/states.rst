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
Creates an SSH private key and sends its associated
public key to the mine for the borg server to recognize it.


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


