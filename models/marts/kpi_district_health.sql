{{
    config(
        materialized='table'
    )
}}

SELECT 
    d.district,
    d.governorate,
    COUNT(DISTINCT f.transformer_id) AS active_transformers,
    SUM(f.kwh) AS total_kwh_consumed,
    COUNT(DISTINCT a.anomaly_id) AS total_anomalies
FROM {{ ref('fact_transformer_readings') }} f
JOIN {{ ref('dim_transformers') }} d 
  ON f.transformer_id = d.transformer_id
LEFT JOIN {{ ref('anomaly_flags') }} a
  ON f.transformer_id = a.transformer_id 
 AND DATE(f.reading_ts) = DATE(a.end_ts)
GROUP BY d.district, d.governorate