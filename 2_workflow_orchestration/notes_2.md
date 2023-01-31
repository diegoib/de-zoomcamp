# Workflow Orchestration

## Table of contents
- [Architecture](#architecture) 
- [Docker and Postgres](#docker-and-postgres)
    - [Docker basic concepts](#docker-basic-concepts)
    - [Running Postgres in a container](#running-postgres-in-a-container)



## Basic concepts
### Data Lake
A data lake is a central repository that holds big data from many sources. This data can be structured, semi-structured or unstructured. The idea is to ingest data as quickly as possible and make it available or accessible to other team members (data scientists, data analysts...).

Generally, when ingesting data to the data lake, we would associate some sort of emtadata for faster access.
- Differences between a data lake and a data warehouse
    - Data lake
        - raw: unstructured
        - large: terabytes
        - undefined
        - users: data scientists, data analysts
        - use cases: stream processing, machine learning, real time analysis
    - Data warehouse
        - refined: structured
        - smaller
        - relational
        - users: business analysts
        - use cases: batch processing, BI, reporting

Gotchas of a data lake:
- converting into a data swamp
- no versioning
- incompatible schemas for the same data without versioning (for example, we write january taxi data in avro format, and next month we write it in parquet)
- no metadata associated
- joins not possible (no foreign keys available...)

And the cloud providers for data lakes are:
- *GCP* - Cloud Storage
- *AWS* - S3
- *Azure* - Blob storage

### ETL vs ELT
- *ETL*
    - stands for Extract, Transform and Load
    - mainly used for a small amount of data. It is data warehouse solution
    - schema on write, well-defined schema, relationships defined, and then we write the data
- *ELT*
    - stands for Extract, Load and Transform
    - used for large amounts of data
    - it is a data lake solution, and provides data lake support (Schema on read). We write the data first and determine the schema on the read