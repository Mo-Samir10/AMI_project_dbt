SELECT 
    transformer_id,
    feeder_id,
    substation_id,
    district,
    governorate,
    capacity_kw,
    lat,
    lon
FROM {{ source('raw', 'grid_transformers') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY transformer_id ORDER BY transformer_id) = 1