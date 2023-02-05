# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_ocsp_service_running = tplroot ~ ".ocsp_fetcher.service.running" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- if certbot.ocsp_fetcher %}

include:
  - {{ sls_ocsp_service_running }}
{%- endif %}

{%- for cert, domains in certbot.certs.items() %}

Certificate '{{ cert }}' is present:
  certbot.present:
    - name: {{ cert }}
    - domains: {{ domains }}
    - options: {{ certbot.cert_config | traverse(cert ~ ":options", certbot.cert_config.default.options) }}
    - auth: {{ certbot.cert_config | traverse(cert ~ ":auth", certbot.cert_config.default.auth) }}
    - install: {{ certbot.cert_config | traverse(cert ~ ":install", certbot.cert_config.default.install) }}
    - binpath: {{ certbot._bin or none }}
{%-   if certbot.ocsp_fetcher %}
    - onchanges_in:
      - OCSP cache is updated directly on changes
{%-   endif %}
{%- endfor %}
