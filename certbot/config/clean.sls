# vim: ft=sls

{#-
    Removes the configuration of the certbot service and has a
    dependency on `certbot.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_service_clean }}

certbot configuration is absent:
  file.absent:
    - name: {{ certbot.lookup.config }}
    - require:
      - sls: {{ sls_service_clean }}
