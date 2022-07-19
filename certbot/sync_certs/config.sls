# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_sync_certs_package = tplroot ~ ".sync_certs.package" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_sync_certs_package }}

sync_certs private key is present:
  file.managed:
    - name: {{ certbot.lookup.sync_certs_ssh_keyfile }}
    - contents_pillar: {{ certbot.sync_certs.ssh_privkey_pillar }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0600'
    - makedirs: true
    - dir_mode: '0700'
    - require:
      - sls: {{ sls_sync_certs_package }}
