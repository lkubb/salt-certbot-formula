# vim: ft=sls

{#-
    *Meta-state*.

    This installs the certbot package,
    manages the certbot configuration file
    and then enables the certbot autorenew timer.
    Also manages issued certificates,
    possibly OCSP fetcher and certsync setup.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - .package
  - .config
  - .service
  - .certs
{%- if certbot.ocsp_fetcher.install %}
  - .ocsp_fetcher
{%- endif %}
{%- if certbot.certsync %}
  - .certsync
{%- endif %}
