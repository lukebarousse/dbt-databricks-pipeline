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
        REGEXP_REPLACE(job_via, '^via ', '') AS source_platform,
        job_posted_at,
        job_schedule_type,
        job_work_from_home,
        search_time AS searched_at,
        search_date,
        search_term,
        search_location,
        job_salary,
        -- lower bound: the number before the en-dash, times its K or M suffix
        {{ parse_salary('min') }} AS salary_min,
        -- upper bound: the same parse on the LAST segment, so a single value is its own range
        {{ parse_salary('max') }} AS salary_max,
        -- pay period, read off the end of the text: 'a year', 'an hour'
        ({{ parse_salary('min') }} + {{ parse_salary('max') }} )/2 AS salary_avg,
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        -- currency marker; a salaried row with no marker is stamped USD on purpose
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency,
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