# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_certsync_package = tplroot ~ "certsync.package" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_certsync_package }}

Certsync user authorized_keys is managed:
  file.managed:
    - name: __slot__:salt:user.info(certsync).home ~ /.ssh/authorized_keys
    - source: {{ files_switch(['certsync/authorized_keys'],
                              lookup='Certsync user authorized_keys is managed'
                 )
              }}
    - mode: '0600'
    - user: certsync
    - group: certsync
    - require:
      - sls: {{ sls_certsync_package }}
