-- Creating external table referring to gcs path 

-- GREEN
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-386310.trips_data_all.external_green_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_de-zoomcamp-386310/data/green/green_tripdata_*.csv.gz']
);

CREATE OR REPLACE TABLE `de-zoomcamp-386310.trips_data_all.green_tripdata` 
PARTITION BY DATE(lpep_pickup_datetime)
AS
SELECT * FROM `de-zoomcamp-386310.trips_data_all.external_green_tripdata`;


-- YELLOW
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-386310.trips_data_all.external_yellow_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_de-zoomcamp-386310/data/yellow/yellow_tripdata_*.csv.gz']
);

CREATE OR REPLACE TABLE `de-zoomcamp-386310.trips_data_all.yellow_tripdata` 
PARTITION BY DATE(tpep_pickup_datetime)
AS
SELECT * FROM `de-zoomcamp-386310.trips_data_all.external_yellow_tripdata`;
