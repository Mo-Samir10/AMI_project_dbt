{{
    config(
        materialized='table'
    )
}}

WITH truth AS (
    SELECT 
        transformer_id,
        event_type,
        end_ts AS truth_end_ts
    FROM {{ source('raw', 'sim_truth') }}
),
detected AS (
    SELECT 
        transformer_id,
        event_type,
        end_ts AS detected_end_ts
    FROM {{ ref('anomaly_flags') }}
),
true_positives AS (
    SELECT 
        t.transformer_id,
        t.event_type,
        t.truth_end_ts,
        d.detected_end_ts,
        'True Positive' AS detection_status
    FROM truth t
    JOIN detected d 
      ON t.transformer_id = d.transformer_id 
     AND t.event_type = d.event_type 
     -- Allows a 15-minute tolerance window for streaming timestamps
     AND ABS(TIMESTAMPDIFF(minute, t.truth_end_ts, d.detected_end_ts)) <= 15
),
false_negatives AS (
    SELECT 
        t.transformer_id,
        t.event_type,
        t.truth_end_ts,
        NULL AS detected_end_ts,
        'False Negative' AS detection_status
    FROM truth t
    LEFT JOIN true_positives tp 
      ON t.transformer_id = tp.transformer_id 
     AND t.event_type = tp.event_type 
     AND t.truth_end_ts = tp.truth_end_ts
    WHERE tp.transformer_id IS NULL
),
false_positives AS (
    SELECT 
        d.transformer_id,
        d.event_type,
        NULL AS truth_end_ts,
        d.detected_end_ts,
        'False Positive' AS detection_status
    FROM detected d
    LEFT JOIN true_positives tp 
      ON d.transformer_id = tp.transformer_id 
     AND d.event_type = tp.event_type 
     AND d.detected_end_ts = tp.detected_end_ts
    WHERE tp.transformer_id IS NULL
)
SELECT * FROM true_positives
UNION ALL
SELECT * FROM false_negatives
UNION ALL
SELECT * FROM false_positives