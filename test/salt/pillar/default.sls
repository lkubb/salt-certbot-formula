# -*- coding: utf-8 -*-
# vim: ft=yaml
---
certbot:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    config: '/etc/letsencrypt/cli.ini'
    service:
      name: certbot
    pip_install_path: /opt/letsencrypt
    pip_reqs:
      - python3-virtualenv
    pkg:
      name: certbot
    rrsync_path: /usr/share/doc/rsync/scripts/rrsync
    rsync: rsync
    sync_certs_ssh_keyfile: /root/.ssh/sync_certs
  cert_config:
    default:
      auth: standalone
      install: false
      options: {}
  certs: {}
  certsync: {}
  config:
    agree-tos: true
    email: foo@example.com
  install_method: pip
  ocsp_fetcher:
    install: false
    nginx_conf: /etc/nginx
    subdir: ocsp-cache
  pip_pkgs: []
  renew:
    rand_delay: 1h
    timer: daily
  sync_certs:
    from: null
    from_host_key: null
    ssh_privkey_pillar: null
    to: /etc/letsencrypt
  version: latest

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://certbot/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   certbot-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      certbot-config-file-file-managed:
        - 'example.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
