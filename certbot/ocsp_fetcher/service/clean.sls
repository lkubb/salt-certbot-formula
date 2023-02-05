# vim: ft=sls

{#-
    Disables the ``certbot-ocsp-fetcher`` timer.
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

certbot-ocsp-fetcher is dead:
  service.dead:
    - name: certbot-ocsp-fetcher.timer
    - enable: false
