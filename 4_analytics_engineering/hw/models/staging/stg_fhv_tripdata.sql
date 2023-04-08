{{ config(materialized='view') }}
 
select
   -- identifiers
    dispatching_base_num, 
    Affiliated_base_number as affiliated_base_number, 
    cast(PUlocationID as integer) as  pickup_locationid, 
    cast(DOlocationID as integer) as dropoff_locationid, 
    
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime, 
    cast(dropOff_datetime as timestamp) as dropoff_datetime, 
    
    -- trip info
    cast(SR_Flag as integer) as sr_flag, 
   
from {{ source('staging','fhv_tripdata_partnclust') }}

-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}