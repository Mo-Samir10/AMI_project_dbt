{% snapshot meters_snapshot %}

{{
    config(
      target_database='SMART_GRID_DB',
      target_schema='CORE',
      unique_key='meter_id',
      strategy='check',
      check_cols=['transformer_id', 'tariff', 'customer_name', 'address']
    )
}}

SELECT * FROM {{ source('raw', 'grid_meters') }}

{% endsnapshot %}