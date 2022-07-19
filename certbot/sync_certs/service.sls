# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_sync_certs_config = tplroot ~ ".sync_certs.config" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_sync_certs_config }}

sync_certs service is running:
  service.running:
    - name: sync_certs.timer
    - enable: true
    - require:
      - sls: {{ sls_sync_certs_config }}

Certificates are synced now once:
  module.run:
    - service.start:
      - name: sync_certs.service
    - onchanges:
      - sync_certs private key is present
      - sync_certs script is present
