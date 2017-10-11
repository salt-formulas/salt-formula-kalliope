{%- if pillar.kalliope is defined %}
include:
{%- if pillar.kalliope.server is defined %}
- kalliope.server
{%- endif %}
{%- endif %}
