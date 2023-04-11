# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Certbot configuration is managed:
  file.managed:
    - name: {{ certbot.lookup.config }}
    - source: {{ files_switch(["cli.ini", "cli.ini.j2"],
                              lookup="Certbot configuration is managed"
                  )
              }}
    - mode: '0644'
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        certbot: {{ certbot | json }}
