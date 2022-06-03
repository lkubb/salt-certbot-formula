# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- for cert in certbot.certs %}

Certificate '{{ cert }}' is absent:
  certbot.absent:
    - name: {{ cert }}
    - binpath: {{ certbot._bin or none }}
{%- endfor %}
