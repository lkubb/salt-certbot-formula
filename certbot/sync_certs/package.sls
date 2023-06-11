# vim: ft=sls

{#-
    Installs ``rsync`` and sync_certs service.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

Rsync is installed:
  pkg.installed:
    - name: {{ certbot.lookup.rsync }}

sync_certs script is present:
  file.managed:
    - name: /usr/local/bin/sync_certs
    - source: {{ files_switch(
                    ["certsync/sync_certs"],
                    config=certbot,
                    lookup="sync_certs script is present",
                 )
              }}
    - template: jinja
    - context:
        certbot: {{ certbot | json }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0744'
    - makedirs: true
    - require:
      - pkg: {{ certbot.lookup.rsync }}

sync_certs service is installed:
  file.managed:
    - names:
      - /etc/systemd/system/sync_certs.service:
        - source: {{ files_switch(
                        ["certsync/sync_certs.service", "certsync/sync_certs.service.j2"],
                        config=certbot,
                        lookup="sync_certs service is installed",
                        indent_width=10
                     )
                  }}
      - /etc/systemd/system/sync_certs.timer:
        - source: {{ files_switch(
                        ["certsync/sync_certs.timer", "certsync/sync_certs.timer.j2"],
                        config=certbot,
                        lookup="sync_certs timer is installed",
                        indent_width=10
                     )
                  }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0644'
    - makedirs: true
    - template: jinja
    - context:
        certbot: {{ certbot | json }}
    - require:
      - file: /usr/local/bin/sync_certs

sync_certs target dir is present:
  file.directory:
    - name: {{ certbot.sync_certs.to }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
{%- if "semanage" | which %}
  selinux.fcontext_policy_present:
    - name: '%{_sysconfdir}/(letsencrypt|certbot)/(live|archive)(/.*)?'
    - sel_type: cert_t
{%- endif %}

Root SSH confdir is present:
  file.directory:
    - name: {{ salt["user.info"]("root").home }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0700'
