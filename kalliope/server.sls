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
  - groups:
    - audio

kalliope_dirs:
  file.directory:
  - names:
    - {{ server.dir.base }}
    - {{ server.dir.config }}
    - {{ server.dir.log }}
    - {{ server.dir.triggers }}
    - {{ server.dir.resources }}/neuron
    - {{ server.dir.resources }}/tts
    - {{ server.dir.resources }}/stt
    - {{ server.dir.resources }}/signal
    - {{ server.dir.resources }}/trigger
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

kalliope_wake_up:
  file.managed:
  - name: {{ server.dir.triggers }}/kalliope.pmdl
  - source: salt://kalliope/files/pmdl/kalliope-{{ server.language }}.pmdl
  - template: jinja
  - user: kalliope
  - mode: 600
  - require:
    - file: kalliope_config_dir

kalliope_vars:
  file.managed:
  - name: {{ server.dir.config }}/variables.yml
  - source: salt://kalliope/files/variables.yml
  - template: jinja
  - user: kalliope
  - mode: 600
  - require:
    - file: kalliope_config_dir

kalliope_brain:
  file.managed:
  - name: {{ server.dir.config }}/brain.yml
  - source: salt://kalliope/files/brain.yml
  - template: jinja
  - user: kalliope
  - mode: 600
  - require:
    - file: kalliope_config_dir

{%- for resource_name, resource in server.resource.iteritems() %}

kalliope_install_resource_{{ resource_name }}:
  cmd.run:
  - name: kalliope install --git-url "{{ resource.source.address }}"
  - onlyif: [ -f "{{ server.dir.resources }}/{{ resource.resource }}/{{ resource_name }}" ]

{%- endfor %}

{%- if grains.get('init', None) == 'systemd' %}

kalliope_service_file:
  file.managed:
  - name: /etc/systemd/system/{{ server.service }}.service
  - source: salt://kalliope/files/kalliope.service
  - template: jinja
  - user: root
  - mode: 644

kalliope_service:
  service.running:
  - name: {{ server.service }}
  - enable: true
  - watch:
    - file: kalliope_service_file
    - file: kalliope_config
    - file: kalliope_brain

{%- endif %}

{%- endif %}
