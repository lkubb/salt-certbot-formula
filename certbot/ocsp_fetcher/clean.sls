# vim: ft=sls

{#-
    Disables ``certbot-ocsp-fetcher`` timer,
    removes the service/timer unit files + package.
#}

include:
  - .service.clean
  - .package.clean
