# vim: ft=sls

{#-
    Disables the certsync timer, removes configuration, scripts,
    service and user.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

Certsync service is dead:
  service.dead:
    - name: certsync.timer
    - enable: false

Certsync files are absent:
  file.absent:
    - names:
      - /usr/local/bin/certsync
      - /etc/systemd/system/certsync.service
      - /etc/systemd/system/certsync.timer
    - require:
      - Certsync service is dead

Certsync user is absent with files:
  user.absent:
    - name: certsync
    - purge: true
    - require:
      - Certsync service is dead
