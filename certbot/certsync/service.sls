# vim: ft=sls

{#-
    Ensures the certsync timer is enabled.
    Syncs certificates during the first run
    (specifically when ``authorized_keys`` or the certsync
    script states report changes).
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_certsync_config = tplroot ~ ".certsync.config" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_certsync_config }}

Certsync service is running:
  service.running:
    - name: certsync.timer
    - enable: true
    - require:
      - sls: {{ sls_certsync_config }}

Certificates are synced now once:
  module.run:
    - service.start:
      - name: certsync.service
    - onchanges:
      - Certsync user authorized_keys is managed
      - Certsync script is present
