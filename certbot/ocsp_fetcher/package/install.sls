# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

certbot-ocsp-fetcher is installed:
  file.managed:
    - name: /usr/local/bin/certbot-ocsp-fetcher
    - source: {{ files_switch(
                    ["certbot-ocsp-fetcher", "certbot-ocsp-fetcher.j2"],
                    config=certbot,
                    lookup="certbot-ocsp-fetcher is installed",
                 )
              }}
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
        - source: {{ files_switch(
                        ["certbot-ocsp-fetcher.service", "certbot-ocsp-fetcher.service.j2"],
                        config=certbot,
                        lookup="certbot-ocsp-fetcher service is installed",
                        indent_width=10,
                     )
                  }}
      - /etc/systemd/system/certbot-ocsp-fetcher.timer:
        - source: {{ files_switch(
                        ["certbot-ocsp-fetcher.timer", "certbot-ocsp-fetcher.timer.j2"],
                        config=certbot,
                        lookup="certbot-ocsp-fetcher timer is installed",
                        indent_width=10,
                     )
                  }}
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
