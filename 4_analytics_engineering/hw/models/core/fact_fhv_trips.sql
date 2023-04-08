{{ config(materialized='table') }}

with dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select 
    tripdata.dispatching_base_num,
    tripdata.affiliated_base_number, 
    tripdata.pickup_locationid, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    tripdata.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    tripdata.pickup_datetime, 
    tripdata.dropoff_datetime, 
    tripdata.sr_flag
from {{ ref('stg_fhv_tripdata') }} as tripdata
inner join dim_zones as pickup_zone
on tripdata.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on tripdata.dropoff_locationid = dropoff_zone.locationid