#!jinja|yaml

{% from 'amavis/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('amavis:lookup')) %}

amavis:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}
  service:
    - {{ datamap.service.ensure|default('running') }}
    - name: {{ datamap.service.name|default('amavis') }}
    - enable: {{ datamap.service.enable|default(True) }}

{% for i in datamap.config.manage|default([]) %}
  {% set f = datamap.config[i] %}
amavis_config_{{ i }}:
  file:
    - managed
    - name: {{ f.path }}
    - source: {{ f.template_path|default('salt://amavis/files/config/' ~ i) }}
    - mode: {{ f.mode|default(644) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('root') }}
    - template: jinja
    - watch_in:
      - service: amavis
{% endfor %}

{% for f in datamap.configs_absent|default([]) %}
configfile_absent_{{ f }}:
  file:
    - absent
    - name: {{ f }}
    - watch_in:
      - service: amavis
{% endfor %}

