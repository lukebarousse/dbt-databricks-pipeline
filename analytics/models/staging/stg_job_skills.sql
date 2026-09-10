WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_skills') }}
),
cleaned AS (
    SELECT
        job_id,
        skill_id,
        TRIM(skill_keyword) AS skill_keyword
    FROM source
)

SELECT * FROM cleaned