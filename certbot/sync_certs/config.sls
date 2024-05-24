# vim: ft=sls

{#-
    Creates an SSH private key. Needs to ensure it will be accepted
    by the host to sync from, either by sending its public key to the mine
    or by generating an SSH client certificate if configured.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_sync_certs_package = tplroot ~ ".sync_certs.package" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- set ssh_pki = "ssh_pki" in salt["saltutil.list_extmods"]()["modules"] %}

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
{%-   if ssh_pki is true %}

sync_certs private key is present:
  ssh_pki.private_key_managed:
    - name: {{ certbot.lookup.sync_certs_ssh_keyfile }}
    - algo: {{ certbot.sync_certs.key_type if certbot.sync_certs.key_type != "ec" else "ecdsa" }}
    - keysize: {{ certbot.sync_certs.key_bits | json }}
{%-     if certbot.sync_certs.ssh_certs %}
    - new: true
{%-       if salt["file.file_exists"](certbot.lookup.sync_certs_ssh_keyfile) %}
    - prereq:
{%-         for cert_name in certbot.sync_certs.ssh_certs %}
      - ssh_pki: {{ certbot.lookup.sync_certs_ssh_keyfile }}_{{ cert_name }}.crt
{%-         endfor %}
{%-       endif %}
{%-     endif %}

sync_certs public key is present:
  ssh_pki.public_key_managed:
    - name: {{ certbot.lookup.sync_certs_ssh_keyfile }}.pub
    - public_key_source: {{ certbot.lookup.sync_certs_ssh_keyfile }}
    - require:
      - ssh_pki: {{ certbot.lookup.sync_certs_ssh_keyfile }}

{%-     for cert_name, cert_config in certbot.sync_certs.ssh_certs.items() %}

sync_certs client cert {{ cert_name }} is present:
  ssh_pki.certificate_managed:
    - name: {{ certbot.lookup.sync_certs_ssh_keyfile }}_{{ cert_name }}.crt
    - cert_type: user
    - private_key: {{ certbot.lookup.sync_certs_ssh_keyfile }}
{%-       for param, val in certbot.sync_certs.ssh_cert_params.items() %}
    - {{ param }}: {{ (cert_config[param] if param in cert_config else val) | json }}
{%-       endfor %}
{%-       if not salt["file.file_exists"](certbot.lookup.sync_certs_ssh_keyfile) %}
    - require:
      - ssh_pki: {{ certbot.lookup.sync_certs_ssh_keyfile }}
{%-       endif %}
    - require_in:
      - sync_certs public key is removed from the mine
{%-     endfor %}

{%-     if certbot.sync_certs.ssh_certs %}

sync_certs public key is removed from the mine:
  module.run:
    - mine.delete:
      - fun: certsync_pubkey
{%-     endif %}

{%-   else %}

sync_certs private key is present:
  cmd.run:
    - name: >
        ssh-keygen -q -N ''
        -t '{{ certbot.sync_certs.key_type }}'
        -f '{{ certbot.lookup.sync_certs_ssh_keyfile }}'
{%-     if certbot.sync_certs.key_bits %}
        -b {{ certbot.sync_certs.key_bits }}
{%-     endif %}
    - creates: {{ certbot.lookup.sync_certs_ssh_keyfile }}
    - require:
      - sls: {{ sls_sync_certs_package }}
{%-   endif %}

{%-   if ssh_pki is false or not certbot.sync_certs.ssh_certs %}

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
{%-   endif %}
{%- endif %}

{%- if certbot.sync_certs.from_host_key %}

sync_certs host key is known:
  ssh_known_hosts.present:
    - name: {{ certbot.sync_certs.from }}
    - user: root
    - key: {{ certbot.sync_certs.from_host_key }}
{%- endif %}
