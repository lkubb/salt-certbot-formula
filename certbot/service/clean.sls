# vim: ft=sls

{#-
    Disables the certbot autorenew timer.
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

certbot autorenew timer is disabled:
  service.dead:
    - name: {{ certbot.lookup.service.name }}.timer
    - enable: False
