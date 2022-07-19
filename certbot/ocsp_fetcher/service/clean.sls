# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

certbot-ocsp-fetcher-service-clean-service-dead:
  service.dead:
    - name: certbot-ocsp-fetcher.timer
    - enable: false
