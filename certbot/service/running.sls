# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_config_file }}

certbot autorenew timer is enabled:
  service.running:
    - name: {{ certbot.lookup.service.name }}.timer
    - enable: True
    - watch:
      - sls: {{ sls_config_file }}
