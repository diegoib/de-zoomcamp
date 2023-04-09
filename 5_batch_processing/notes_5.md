# Batch Processing

## Table of contents
- [Basic concepts](#basic_-concepts) 
    - [Analytics Engineering Basics](#analytics-engineering-basics)
    - [ETL vs ELT](#etl-vs-elt)

## Basic Concepts
### Batch pocessing

There are 2 ways of processing data: batch and streaming. In `batch processing` we take and process a chunck of data at the same time. It can be, for example, running a job that takes as input all the rows corresponding to the month january, and procuce a new dataset. In `streaming processing` the data is taken and processed on the fly, it means record by record at the moment the record is being generated. The way of processing is going to be adressed in next module.

Batch jobs are usually run at different **time intervals**:
- weekly
- daily
- hourly
- 3 times per hour
- every 5 minutes
Most common ones are daily and hourly.

The **technologies** used to run these jobs are:
- python scripts (seen at week 2): can be run anywhere, such us kubernetes, aws batch... and what it is tipically used to orchestrate these jobs is prefect / airflow.
- sql (seen at week 4)
- spark
- flink
- ...

Some **advantages** of batch jobs are:
- easy to manage: we can define steps, parametrize the scripts
- retry, in case of failure
- scale 

And some **disadvantages** are:
- delay, as we run the jobs in regular intervals we have to wait then to the run to be able to analyse the latest data. The same with the processing time needed for the job to be run.