# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_package_install }}

certbot-ocsp-fetcher is installed:
  file.managed:
    - name: /usr/local/bin/certbot-ocsp-fetcher
    - source: salt://certbot/files/default/certbot-ocsp-fetcher
    - mode: '0744'
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
    - require:
      - sls: {{ sls_package_install }}

certbot-ocsp-fetcher service is installed:
  file.managed:
    - names:
      - /etc/systemd/system/certbot-ocsp-fetcher.service:
        - source: salt://certbot/files/default/certbot-ocsp-fetcher.service
      - /etc/systemd/system/certbot-ocsp-fetcher.timer:
        - source: salt://certbot/files/default/certbot-ocsp-fetcher.timer
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - makedirs: true
    - mode: '0644'
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
      - file: /usr/local/bin/certbot-ocsp-fetcher
    - context:
        certbot: {{ certbot | json }}

OCSP cache dir is present:
  file.directory:
    - name: {{ certbot.ocsp_fetcher.nginx_conf | path_join(certbot.ocsp_fetcher.subdir) }}
    - user: root
    - group: {{ certbot.lookup.rootgroup }}
    - mode: '0644'
    - makedirs: true
    - require:
      - sls: {{ sls_package_install }}
