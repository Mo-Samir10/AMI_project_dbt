# Smart Grid Power Monitoring & Anomaly Detection (dbt Pipeline)

This repository contains the dbt (data build tool) transformation pipeline for the Smart Grid Power Monitoring and Electricity Theft Detection system. It processes raw streaming meter and transformer data from AWS S3 into a highly optimized Snowflake data warehouse, delivering clean dimensional models and detecting grid anomalies in near real-time.

## Architecture & Data Flow

-   **Raw Layer (Snowflake `RAW`):** Continuous ingestion of 15-minute interval data (meter readings, transformer metrics) and simulated anomaly truths via S3 external stages.
-   **Transformation (dbt-core):** Cleanses data, manages Slowly Changing Dimensions (SCD Type 2), and executes incremental business logic.
-   **Gold Layer (Snowflake `MARTS`):** Provides a star schema, anomaly flags, and pre-aggregated KPI tables ready for downstream orchestration (Apache Airflow) and visualization (Power BI).

## Core Models

### 1. Dimensional Modeling
-   `dim_transformers`: Static geographic and network attributes for street boxes.
-   `dim_meters`: SCD Type 2 historical tracking of customer meters and tariff assignments via dbt snapshots.
-   `fact_meter_readings` & `fact_transformer_readings`: Cleansed 15-minute energy consumption and voltage logs.

### 2. Anomaly Detection (Incremental)
Identifies grid irregularities and handles inherent 0.5% data duplication gracefully:
-   `check_overload`: Flags transformers exceeding 85% capacity for two consecutive readings.
-   `check_line_drop`: Flags sustained voltage drops under 207V for a full hour.
-   `check_theft`: Flags locations with >11% unbilled energy loss over a 4-hour rolling window.
-   `anomaly_flags`: A unified view consolidating all detected events.

### 3. Business KPIs & Accuracy
-   `accuracy_metrics` & `accuracy_summary`: Compares detected anomalies against the simulator's answer key per transformer and problem type, generating precision and recall scores for True/False Positives and Negatives.
-   `kpi_daily_demand` & `kpi_transformer_peak`: Aggregates the true network peak load and total energy consumption.
-   `kpi_anomaly_summary` & `kpi_district_health`: Summarizes daily events and geographic distribution for Power BI map rendering.

## Setup & Execution

**1. Configure Profile**
Ensure your `profiles.yml` is configured to connect to the `SMART_GRID_DB` Snowflake database using the dedicated `DBT_ROLE` and `DBT_USER`. Update the project reference to `smart_grid`.

**2. Install Dependencies**
```bash
dbt deps
```

**3. Snapshot Historical Data**
Capture Slowly Changing Dimensions (SCD2) for meters moving across the grid:
```bash
dbt snapshot
```

**4. Build the Pipeline**
Run the full project to process dimensional and incremental fact models:
```bash
dbt run
```

**5. Run Data Quality Tests**
Execute uniqueness and not-null assertions against the generated data warehouse. (Note: A dedicated quality gate test is tagged 'demo' and designed to fail for grading demonstration purposes).
```bash
dbt test --exclude tag:demo
```