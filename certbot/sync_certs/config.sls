# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_sync_certs_package = tplroot ~ ".sync_certs.package" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_sync_certs_package }}

{%- if certbot.sync_certs.ssh_privkey_pillar %}

sync_certs private key is present:
  file.managed:
    - name: {{ certbot.lookup.sync_certs_ssh_keyfile }}
    - contents_pillar: {{ certbot.sync_certs.ssh_privkey_pillar }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0600'
    - require:
      - sls: {{ sls_sync_certs_package }}
{%- else %}

sync_certs private key is present:
  cmd.run:
    - name: >
        ssh-keygen -q -N ''
        -t '{{ certbot.sync_certs.key_type }}'
        -f '{{ certbot.lookup.sync_certs_ssh_keyfile }}'
{%-  if certbot.sync_certs.key_bits %}
        -b {{ certbot.sync_certs.key_bits }}
{%-  endif %}
    - creates: {{ certbot.lookup.sync_certs_ssh_keyfile }}
    - require:
      - sls: {{ sls_sync_certs_package }}

sync_certs public key is sent to the mine:
  module.run:
    - mine.send:
      - name: certsync_pubkey
      - mine_function: file.read
      - allow_tgt: 'certsync_role:server'
      - allow_tgt_type: pillar
      - path: {{ certbot.lookup.sync_certs_ssh_keyfile }}.pub
      - binary: false
    - require:
      - sync_certs private key is present
{%- endif %}

{%- if certbot.sync_certs.from_host_key %}

sync_certs host key is known:
  ssh_known_hosts.present:
    - name: {{ certbot.sync_certs.from }}
    - user: root
    - key: {{ certbot.sync_certs.from_host_key }}
{%- endif %}
