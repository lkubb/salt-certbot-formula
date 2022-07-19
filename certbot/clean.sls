# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
{%- if certbot.ocsp_fetcher.install %}
  - .ocsp_fetcher.clean
{%- endif %}
  - .certs.clean
  - .service.clean
  - .config.clean
  - .package.clean
