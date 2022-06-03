# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_service_clean }}

certbot-config-clean-file-absent:
  file.absent:
    - name: {{ certbot.lookup.config }}
    - require:
      - sls: {{ sls_service_clean }}
