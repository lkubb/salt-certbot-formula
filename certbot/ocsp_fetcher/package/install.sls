# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_package_install }}

certbot-ocsp-fetcher is installed:
  file.managed:
    - names:
      - /usr/local/bin/certbot-ocsp-fetcher:
        - source: salt://certbot/files/certbot-ocsp-fetcher
        - mode: '0744'
      - /etc/systemd/system/certbot-ocsp-fetcher.service:
        - source: salt://certbot/files/certbot-ocsp-fetcher.service
        - template: jinja
      - /etc/systemd/system/certbot-ocsp-fetcher.timer:
        - source: salt://certbot/files/certbot-ocsp-fetcher.timer
        - template: jinja
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
    - mode: '0644'
    - require:
      - sls: {{ sls_package_install }}
