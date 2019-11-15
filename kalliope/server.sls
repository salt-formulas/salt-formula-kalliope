{%- from "kalliope/map.jinja" import server with context %}
{%- if server.enabled %}

kalliope_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{{ server.dir.base }}:
  virtualenv.manage:
  - system_site_packages: True
  - python: {{ server.python }}
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

kalliope_ding:
  file.managed:
  - name: {{ server.dir.base }}/bin/ding.sh
  - source: salt://kalliope/files/ding.sh
  - template: jinja
  - user: kalliope
  - mode: 755
  - require:
    - file: kalliope_config_dir

kalliope_dong:
  file.managed:
  - name: {{ server.dir.base }}/bin/dong.sh
  - source: salt://kalliope/files/dong.sh
  - template: jinja
  - user: kalliope
  - mode: 755
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

{%- for synapse_name, synapse in server.get('synapse', {}).iteritems() %}
  {%- for item in synapse.neurons %}
    {%- set neuron_index = loop.index0 %}
    {%- for neuron_name, neuron in item.iteritems() %}
      {%- if neuron.get('template') %}
        {%- set neuron_file_template = neuron.get('file_template', server.dir.config+"/templates/"+synapse_name+"_"+neuron_name+".j2") %}

kalliope_template_{{ synapse_name }}_{{ neuron_name }}:
  file.managed:
    - name: {{ neuron_file_template }}
    - contents_pillar: kalliope:server:synapse:{{ synapse_name }}:neurons:{{ neuron_index }}:{{ neuron_name }}:template
    - makedirs: true
    - require:
      - file: kalliope_config_dir

      {%- endif %}
    {%- endfor %}
  {%- endfor %}
{%- endfor %}

{%- for resource_name, resource in server.resource.iteritems() %}

kalliope_install_resource_{{ resource_name }}:
  cmd.run:
  - name: {{ server.dir.base }}/bin/kalliope install --git-url "{{ resource.source.address }}"
  - creates: {{ server.dir.resources }}/{{ resource_name }}

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
