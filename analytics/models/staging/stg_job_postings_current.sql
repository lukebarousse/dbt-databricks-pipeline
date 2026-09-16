{{ config(materialized='ephemeral') }}

SELECT *
FROM {{ ref('stg_job_postings') }}
WHERE search_date <= CAST('{{ var('as_of', run_started_at)}}' AS DATE)
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_id
    ORDER BY searched_at DESC
) = 1