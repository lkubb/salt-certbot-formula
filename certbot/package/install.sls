# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

{%- if "pip" == certbot.install_method %}

Requisites to install Certbot in virtualenv are installed:
  pkg.installed:
    - pkgs: {{ certbot.lookup.pip_reqs | json }}

Certbot is installed:
  virtualenv.managed:
    - name: {{ certbot.lookup.pip_install_path }}
    - python: python3
    - pip_upgrade: {{ "latest" == certbot.version }}
    - pip_pkgs:
{%-   if "latest" != certbot.version %}
      - certbot=={{ version }}
{%-   else %}
      - certbot
{%-   endif %}
{%-   for pkg in certbot.pip_pkgs %}
      - {{ pkg }}
{%-   endfor %}
  file.symlink:
    - name: /usr/local/bin/certbot
    - target: {{ certbot.lookup.pip_install_path | path_join("bin", "certbot") }}
{%- else %}

Certbot is installed:
  pkg.installed:
    - name: {{ certbot.lookup.pkg.name }}
{%- endif %}

Certbot renew unit files are available:
  file.managed:
    - names:
      - /etc/systemd/system/{{ certbot.lookup.service.name }}.service:
        - source: {{ files_switch(
                        ["certbot.service", "certbot.service.j2"],
                        config=certbot,
                        lookup="Certbot renew service is installed",
                        indent_width=10,
                     )
                  }}
      - /etc/systemd/system/{{ certbot.lookup.service.name }}.timer:
        - source: {{ files_switch(
                        ["certbot.timer", "certbot.timer.j2"],
                        config=certbot,
                        lookup="Certbot renew timer is installed",
                        indent_width=10,
                     )
                  }}
    - mode: '0644'
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - Certbot is installed
    - context:
        certbot: {{ certbot | json }}

# This syncs all modules. Specifying a whitelist removes all
# other modules.
Custom Certbot modules are synced:
  saltutil.sync_all:
    - refresh: true
