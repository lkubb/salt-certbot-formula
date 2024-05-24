# vim: ft=sls

{#-
    Enables the sync_certs timer and tries to synchronize
    certificates once.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_sync_certs_config = tplroot ~ ".sync_certs.config" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

{%- set id_files = ["'{}'".format(certbot.lookup.sync_certs_ssh_keyfile)] %}
{%- if certbot.sync_certs.ssh_certs %}
{%-   do id_files.append("'{}_{}.crt'".format(certbot.lookup.sync_certs_ssh_keyfile, certbot.sync_certs.ssh_certs | first)) %}
{%- endif %}

include:
  - {{ sls_sync_certs_config }}

sync_certs service is running:
  service.running:
    - name: sync_certs.timer
    - enable: true
    - require:
      - sls: {{ sls_sync_certs_config }}

Certificates are synced now once:
  cmd.run:
    # This form ensures only the first connection has to be untrusted
    # if the host key was not specified.
    - name: >-
        rsync -aiz -e
        "ssh {{- ' -o StrictHostKeyChecking=no'
                    if not certbot.sync_certs.from_host_key
                    and "add" == salt["ssh.check_known_host"](user="root", hostname=certbot.sync_certs.from) }}
        -i {{ id_files | join(" -i ") }}
        certsync@{{ certbot.sync_certs.from }}:* {{ certbot.sync_certs.to }}/
  # module.run:
  #   - service.start:
  #     - name: sync_certs.service
    - unless:
      - test -n "$(ls -A '{{ certbot.sync_certs.to }}')"
