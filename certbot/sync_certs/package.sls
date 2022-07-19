# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Rsync is installed:
  pkg.installed:
    - name: {{ certbot.lookup.rsync }}

sync_certs script is present:
  file.managed:
    - name: /usr/local/bin/sync_certs
    - source: {{ files_switch(['certsync/sync_certs'],
                              lookup='sync_certs script is present'
                 )
              }}
    - template: jinja
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
        - source: {{ files_switch(['certsync/sync_certs.service', 'sync_certs.service.j2'],
                                  lookup='sync_certs service is installed',
                                  indent_width=10
                     )
                  }}
      - /etc/systemd/system/sync_certs.timer:
        - source: {{ files_switch(['certsync/sync_certs.timer', 'sync_certs.timer.j2'],
                                  lookup='sync_certs timer is installed',
                                  indent_width=10
                     )
                  }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0700'
    - makedirs: true
    - require:
      - file: /usr/local/bin/sync_certs

sync_certs target dir is present:
  file.directory:
    - name: {{ certbot.sync_certs.to }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
{%- if salt["cmd.run"]("command -v semanage") %}
  selinux.fcontext_policy_present:
    - name: '%{_sysconfdir}/(letsencrypt|certbot)/(live|archive)(/.*)?'
    - sel_type: cert_t
{%- endif %}
