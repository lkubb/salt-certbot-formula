# vim: ft=sls

{#-
    Removes the certbot package.
    Has a dependency on `certbot.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_config_clean }}

Certbot renew unit files are absent:
  file.absent:
    - names:
      - /etc/systemd/system/{{ certbot.lookup.service.name }}.service
      - /etc/systemd/system/{{ certbot.lookup.service.name }}.timer

{%- if "pip" == certbot.install_method %}
{%-   if grains.os_family == "Debian" and (grains.osmajorrelease >=12 or (grains.os == "Ubuntu" and grains.osmajorrelease >=23)) %}

Certbot is removed:
  cmd.run:
    - name: pipx uninstall certbot
    - env:
        PIPX_HOME: /opt/pipx
        PIPX_BIN_DIR: /usr/local/bin
        PIPX_MAN_DIR: /usr/local/share/man
    - onlyif:
      - pipx list --short | grep certbot

{%-   else %}

Certbot is removed:
  file.absent:
    - names:
      - {{ certbot.lookup.pip_install_path }}
      - /usr/local/bin/certbot
{%-   endif %}
{%- else %}

Certbot is removed:
  pkg.removed:
    - name: {{ certbot.lookup.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
{%- endif %}
