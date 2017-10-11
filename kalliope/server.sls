{%- from "kalliope/map.jinja" import server with context %}
{%- if server.enabled %}

kalliope_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{{ server.dir.base }}:
  virtualenv.manage:
  - system_site_packages: True
  - requirements: salt://kalliope/files/requirements.txt
  - require:
    - pkg: kalliope_packages

kalliope_user:
  user.present:
  - name: kalliope
  - system: true
  - home: {{ server.dir.base }}
  - require:
    - virtualenv: {{ server.dir.base }}

kalliope_dirs:
  file.directory:
  - names:
    - /etc/kalliope
    - /var/log/kalliope
  - mode: 700
  - makedirs: true
  - user: kalliope
  - require:
    - virtualenv: {{ server.dir.base }}

kalliope_config_dir:
  file.directory:
  - name: {{ server.dir.config }}
  - mode: 700
  - makedirs: true
  - user: kalliope
  - require:
    - virtualenv: {{ server.dir.base }}

kalliope_config:
  file.managed:
  - name: {{ server.dir.config }}/settings.yml
  - source: salt://kalliope/files/settings.yml
  - template: jinja
  - user: kalliope
  - mode: 600
  - require:
    - file: kalliope_config_dir

kalliope_brain:
  file.managed:
  - name: /etc/kalliope/known_devices.yaml
  - source: salt://kalliope/files/known_devices.yaml
  - template: jinja
  - user: kalliope
  - mode: 600
  - require:
    - file: kalliope_dir

{%- endif %}
