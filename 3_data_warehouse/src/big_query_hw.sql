-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-386310.trips_data_all.external_fhv_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_de-zoomcamp-386310/data/fhv/fhv_tripdata_2019-*.csv.gz']
);

select * from `de-zoomcamp-386310.trips_data_all.external_fhv_tripdata` limit 10;

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE `de-zoomcamp-386310.trips_data_all.fhv_tripdata_non_partitioned` AS
SELECT * FROM `de-zoomcamp-386310.trips_data_all.external_fhv_tripdata`;



select count(1) from `de-zoomcamp-386310.trips_data_all.external_fhv_tripdata`;

--Question 2
SELECT COUNT(DISTINCT Affiliated_base_number) FROM `de-zoomcamp-386310.trips_data_all.external_fhv_tripdata`; --0 MB
SELECT COUNT(DISTINCT Affiliated_base_number) FROM `de-zoomcamp-386310.trips_data_all.fhv_tripdata_non_partitioned`; --317.94 MB

--Question 3
SELECT 
  COUNT(*) 
FROM 
  `de-zoomcamp-386310.trips_data_all.fhv_tripdata_non_partitioned`
WHERE 
  PUlocationID IS NULL
  AND DOlocationID IS NULL; --717748

--Question 4
--Partition by pickup_datetime Cluster on affiliated_base_number

--Question 5
CREATE OR REPLACE TABLE `de-zoomcamp-386310.trips_data_all.fhv_tripdata_partnclust` 
PARTITION BY DATE(pickup_datetime)
CLUSTER BY affiliated_base_number
AS
SELECT * FROM `de-zoomcamp-386310.trips_data_all.external_fhv_tripdata`;

SELECT 
  COUNT(DISTINCT affiliated_base_number)
FROM 
  `de-zoomcamp-386310.trips_data_all.fhv_tripdata_partnclust`
WHERE
  DATE(pickup_datetime) BETWEEN '2019-03-01' AND '2019-03-31'; --23,05 MB

SELECT 
  COUNT(DISTINCT affiliated_base_number)
FROM 
  `de-zoomcamp-386310.trips_data_all.fhv_tripdata_non_partitioned`
WHERE
  DATE(pickup_datetime) BETWEEN '2019-03-01' AND '2019-03-31'; --647,87 MB

--Question 6
--GCP Bucket

--Question 7
--False