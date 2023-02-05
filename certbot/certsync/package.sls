# vim: ft=sls

{#-
    Install ``rsync``, certsync user, script and service [timer].
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Rsync is installed:
  pkg.installed:
    - name: {{ certbot.lookup.rsync }}

Certsync user is present:
  user.present:
    - name: certsync
    - system: true
    - createhome: true

rrsync script is present in user dir:
  file.copy:
    - name: __slot__:salt:user.info(certsync).home ~ /bin/rrsync
    - source: {{ certbot.lookup.rrsync_path }}
    - user: certsync
    - group: certsync
    - mode: '0744'
    - makedirs: true
    - require:
      - pkg: {{ certbot.lookup.rsync }}

SSH config dir is present:
  file.directory:
    - name: __slot__:salt:user.info(certsync).home ~ /.ssh
    - mode: '0700'
    - user: certsync
    - group: certsync
    - require:
      - user: certsync

Certsync script is present:
  file.managed:
    - name: /usr/local/bin/certsync
    - source: {{ files_switch(['certsync/certsync'],
                              lookup='Certsync script is present'
                 )
              }}
    - template: jinja
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0744'
    - makedirs: true
    - require:
      - user: certsync

Certsync service is installed:
  file.managed:
    - names:
      - /etc/systemd/system/certsync.service:
        - source: {{ files_switch(['certsync/certsync.service', 'certsync/certsync.service.j2'],
                                  lookup='Certsync service is installed',
                                  indent_width=10
                     )
                  }}
      - /etc/systemd/system/certsync.timer:
        - source: {{ files_switch(['certsync/certsync.timer', 'certsync/certsync.timer.j2'],
                                  lookup='Certsync timer is installed',
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
      - file: /usr/local/bin/certsync
