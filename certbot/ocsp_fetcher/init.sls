# vim: ft=sls

{#-
    Installs ``certbot-ocsp-fetcher`` + service/timer and enables it.
#}

include:
  - .package
  - .service
