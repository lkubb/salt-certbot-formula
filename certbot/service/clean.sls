# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

certbot-service-clean-service-dead:
  service.dead:
    - name: {{ certbot.lookup.service.name }}.timer
    - enable: False
