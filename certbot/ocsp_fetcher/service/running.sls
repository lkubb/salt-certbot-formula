# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_ocsp_package_install = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_ocsp_package_install }}

certbot-ocsp-fetcher-service-running-service-running:
  service.running:
    - name: certbot-ocsp-fetcher.timer
    - enable: True
    - require:
      - sls: {{ sls_ocsp_package_install }}
