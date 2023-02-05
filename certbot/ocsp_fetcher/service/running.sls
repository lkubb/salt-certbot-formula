# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_ocsp_package_install = tplroot ~ '.ocsp_fetcher.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}

include:
  - {{ sls_ocsp_package_install }}

certbot-ocsp-fetcher is running:
  service.running:
    - name: certbot-ocsp-fetcher.timer
    - enable: true
    - require:
      - sls: {{ sls_ocsp_package_install }}

OCSP cache is updated directly on changes:
  module.run:
    - service.start:
      - name: certbot-ocsp-fetcher.service
    - onchanges:
      - OCSP cache dir is present
