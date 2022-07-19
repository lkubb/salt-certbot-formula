# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
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
