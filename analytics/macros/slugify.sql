{% macro slugify(text) -%}
{{ text | lower | replace(' ', '_')}}
{%- endmacro %}