{{
    config(
        materialized='table'
    )
}}

SELECT 
    DATE(reading_ts) AS demand_date,
    SUM(kwh) AS total_daily_kwh,
    MAX(kw) AS peak_network_kw
FROM {{ ref('fact_transformer_readings') }}
GROUP BY DATE(reading_ts)
ORDER BY demand_date DESC