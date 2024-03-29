# vim: ft=sls

{#-
    Removes ``certbot-ocsp-fetcher`` + service/timer unit files.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_ocsp_service_clean = tplroot ~ ".ocsp_fetcher.service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_ocsp_service_clean }}

certbot-ocsp-fetcher is removed:
  file.absent:
    - names:
      - /usr/local/bin/certbot-ocsp-fetcher
      - /etc/systemd/system/certbot-ocsp-fetcher.service
      - /etc/systemd/system/certbot-ocsp-fetcher.timer
      - {{ certbot.lookup.ocsp_cache }}
    - require:
      - sls: {{ sls_ocsp_service_clean }}
