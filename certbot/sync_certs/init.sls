# vim: ft=sls

{#-
    Installs ``rsync`` + sync_cert scripts, generates SSH keys
    and sends those to the mine for server registration.
    Also enables a ``sync_certs`` timer and tries to synchronize
    certificates from the upstream server with the ``root`` user account.

    Needs to be targeted to hosts that should be able to pull LE certificates
    that are not reachable from the public internet.
#}

include:
  - .package
  - .config
  - .service
