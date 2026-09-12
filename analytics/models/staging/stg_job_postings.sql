{% set extension_keywords = [
    "No degree mentioned", 
    "Health insurance", 
    "Dental insurance", 
    "Paid time off" ]
%}

WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    WHERE error IS NOT TRUE
),
parsed AS (
    SELECT 
        *,
        FROM_JSON(job_extensions_raw, 'array<string>') AS job_extensions
    FROM source
),
cleaned AS (
    SELECT
        job_id,
        job_title,
        TRIM(company_name) AS company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via ', ''),
        job_posted_at,
        job_salary,
        job_schedule_type,
        job_work_from_home,
        search_time AS searched_at,
        search_date,
        search_term,
        search_location,
        {% for keyword in extension_keywords -%}
        ARRAY_CONTAINS(
            job_extensions,
            "{{keyword}}"
        ) AS has_{{ slugify(keyword) }}
        {{- "," if not loop.last}}
        {% endfor %}
    FROM parsed
)
SELECT *
FROM cleaned