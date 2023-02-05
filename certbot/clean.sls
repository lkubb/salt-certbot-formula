# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``certbot`` meta-state
    in reverse order, i.e.
    removes certsync and ocsp fetcher,
    removes the managed certificates and private keys,
    disables the autorenew timer,
    removes the configuration file and then
    uninstalls the package.
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
{%- if certbot.certsync %}
  - .certsync.clean
{%- endif %}
{%- if certbot.ocsp_fetcher.install %}
  - .ocsp_fetcher.clean
{%- endif %}
  - .certs.clean
  - .service.clean
  - .config.clean
  - .package.clean
