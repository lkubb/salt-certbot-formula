# vim: ft=sls

{#-
    Manages ``authorized_keys`` configuration for the certsync user.
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_certsync_package = tplroot ~ ".certsync.package" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_certsync_package }}

Certsync user authorized_keys is managed:
  file.managed:
    - name: __slot__:salt:user.info(certsync).home ~ /.ssh/authorized_keys
    - source: {{ files_switch(['certsync/authorized_keys', 'certsync/authorized_keys.j2'],
                              lookup='Certsync user authorized_keys is managed'
                 )
              }}
    - mode: '0600'
    - user: certsync
    - group: certsync
    - template: jinja
    - require:
      - sls: {{ sls_certsync_package }}
    - context:
        certbot: {{ certbot | json }}
