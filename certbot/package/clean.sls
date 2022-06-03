# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_config_clean }}

{%- if "pip" == certbot.install_method %}

Certbot is absent:
  file.absent:
    - name: {{ certbot.lookup.pip_install_path }}
{%- else %}

certbot-package-clean-pkg-removed:
  pkg.removed:
    - name: {{ certbot.lookup.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
{%- endif %}

{%- if certbot.renew.install %}

Certbot renew unit files are absent:
  file.absent:
    - names:
      - /etc/systemd/system/{{ certbot.lookup.service.name }}.service
      - /etc/systemd/system/{{ certbot.lookup.service.name }}.timer
{%- endif %}
