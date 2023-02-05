# vim: ft=sls

{#-
    Installs ``rsync`` and configures a dedicated user account
    intended to be used to sync LE certificates to hosts behind
    a DMZ. Certificates are regularly synced to subdirectories
    in this user's home directory. Downstream hosts can submit
    public keys, which will be given very restricted access to
    the associated directory only (using ``rrsync``).

    Needs to be targeted to the server accessible from the
    public internet.
#}

include:
  - .package
  - .config
  - .service
