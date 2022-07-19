# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
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
      - {{ certbot.ocsp_fetcher.nginx_conf | path_join(certbot.ocsp_fetcher.subdir) }}
    - require:
      - sls: {{ sls_ocsp_service_clean }}
