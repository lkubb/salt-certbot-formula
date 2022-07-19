# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

sync_certs service is dead:
  service.dead:
    - name: sync_certs.timer
    - enable: false

sync_certs files are absent:
  file.absent:
    - names:
      - {{ certbot.lookup.sync_certs_ssh_keyfile }}
      - /usr/local/bin/sync_certs
      - /etc/systemd/system/sync_certs.service
      - /etc/systemd/system/sync_certs.timer
    - require:
      - sync_certs service is dead

{%- if certbot.sync_certs.from_host_key %}

sync_certs host key is unknown:
  ssh_known_hosts.absent:
    - name: {{ certbot.sync_certs.from }}
    - user: root
{%- endif %}
