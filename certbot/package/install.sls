# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as certbot with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

{%- if certbot.install_method == "pip" %}
{%-   set req_pkgs = [certbot.lookup.pkg.reqs.python, certbot.lookup.pkg.reqs.pip] %}
{%-   do req_pkgs.extend(certbot.lookup.pkg.reqs.certbot) %}

Certbot required packages are installed:
  pkg.installed:
    - pkgs: {{ req_pkgs | json }}

{%-   if grains.os_family == "Debian" and (grains.osmajorrelease >=12 or (grains.os == "Ubuntu" and grains.osmajorrelease >=23)) %}
{#-     Dirty workaround for the system python being marked as externally managed @TODO migrate most to pipx + update pipx modules #}

pipx is installed for certbot:
  pkg.installed:
    - name: pipx

Certbot is installed:
  cmd.run:
    - name: pipx install certbot
    - env:
        PIPX_HOME: /opt/pipx
        PIPX_BIN_DIR: /usr/local/bin
        PIPX_MAN_DIR: /usr/local/share/man
    - unless:
      - pipx list --short | grep certbot
    - require:
      - pkg: pipx
      - Certbot required packages are installed

{%-   else %}
{%-     set pip =
          salt["cmd.which_bin"](["/bin/pip3", "/usr/bin/pip3", "/bin/pip", "/usr/bin/pip"]) or
          '__slot__:salt:cmd.which_bin(["/bin/pip3", "/usr/bin/pip3", "/bin/pip", "/usr/bin/pip"])'
%}

Virtualenv is installed for certbot:
{#-
    Assume that venv_bin is only set when using pip.
    This whole house of cards would be unnecessary if
    the virtualenv module could use the inbuilt venv lib
#}
{%-     if not certbot.lookup.venv_bin.startswith("/") %}
  pkg.installed:
    - name: {{ certbot.lookup.pkg.reqs.venv.pkg }}
{%-     else %}
  pip.installed:
    - name: {{ certbot.lookup.pkg.reqs.venv.pip }}
    - bin_env: {{ pip }}
    - require:
      - Certbot required packages are installed
{%-     endif %}
    - require_in:
      - Certbot is installed

Certbot is installed:
  virtualenv.managed:
    - name: {{ certbot.lookup.pip_install_path }}
    - python: python3
    - venv_bin: {{ certbot.lookup.venv_bin }}
    - pip_upgrade: {{ certbot.version == "latest" }}
    - pip_pkgs:
{%-   if certbot.version != "latest" %}
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
    - require:
      - virtualenv: {{ certbot.lookup.pip_install_path }}
{%-   endif %}
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
    - unless:
      - '{{ ("certbot" in salt["saltutil.list_extmods"]().get("states", [])) | lower }}'
