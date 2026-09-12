{% macro parse_salary(part) -%}
    {%- if part == 'min' -%}
         {%- set segment = "SPLIT(job_salary, '–')[0]" -%}
    {%- else -%}
        {%- set segment = "ELEMENT_AT(SPLIT(job_salary, '–'), -1)" -%}
    {%- endif -%}
        TRY_CAST(REPLACE(REGEXP_EXTRACT({{ segment }}, '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT({{ segment }}, '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END
{%- endmacro %}