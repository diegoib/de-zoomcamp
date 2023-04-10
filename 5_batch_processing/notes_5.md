# Batch Processing

## Table of contents
- [Basic concepts](#basic_-concepts) 
    - [Analytics Engineering Basics](#analytics-engineering-basics)
    - [ETL vs ELT](#etl-vs-elt)


> This notes include contents from this [repo](https://github.com/ziritrion/dataeng-zoomcamp/blob/main/notes/5_batch_processing.md)

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

## Spark
### Introduction to Spark
It is a multilanguage data processing engine. 
- It is an engine in the way that it takes data from a database, makes some transormations over it, and loads it back to another database.
- It is multilanguage because you can use Java and Scala (Scala is the native way of communicating with Spark as Spark is written in Scala), and there are wrappers for python (it is called pyspark) and R.

Spark is used for executing batch jobs, but it can also be used for streaming (you can see streaming as a sequence of small batches).

When to use Spark?
- when the data is in a data lake (some location in GCS / S3 / Blob) sstored, for example, in parquet files. Then Spark pulls this data, do some processing, and then put this data back to the data lake. We would use it for the same things we use SQL, but in this case we don't have a data warehouse. When we have a data warehouse (BigQuery...) we can use SQL, but SQL is not alway easy to use when what we have is a bunch of parquet files (although there are some tools to run SQL over a data lake such us HIVE, Presto, AWS Athena...). if we can express our job with SQL, it is normally better to go with this last solutions. But sometimes we need more flexibility, that is when we would use Spark.

A tipical machine learning workflow involving Saprk would be:

![spark workflow](../images/05_01_spark_workflow.png)

### Installing Spark

To install Spark on a Linux machine (in my case a google virtual machine) follow this [tutorial](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_5_batch_processing/setup/linux.md). We will need to install Java first, and then Spark, and export some variables to everything be able to work fine.


## First look at Spark/PySpark

>Note: if you're running Spark and Jupyter Notebook on a remote machine, you will need to redirect ports 8888 for Jupyter Notebook and 4040 for the Spark UI.

### Creating a Spark session

_[Video Source](https://www.youtube.com/watch?v=r_Sf6fCB40c&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=50)_

We can use Spark with Python code by means of PySpark. We will be using Jupyter Notebooks for this lesson.

We first need to import PySpark to our code:

```python
import pyspark
from pyspark.sql import SparkSession
```

We now need to instantiate a ***Spark session***, an object that we use to interact with Spark.

```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```
* `SparkSession` is the class of the object that we instantiate. `builder` is the builder method.
* `master()` sets the Spark _master URL_ to connect to. The `local` string means that Spark will run on a local cluster. `[*]` means that Spark will run with as many CPU cores as possible.
* `appName()` defines the name of our application/session. This will show in the Spark UI.
* `getOrCreate()` will create the session or recover the object if it was previously created.

Once we've instantiated a session, we can access the Spark UI by browsing to `localhost:4040`. The UI will display all current jobs. Since we've just created the instance, there should be no jobs currently running.

_[Back to the top](#)_

### Reading CSV files

Similarlly to Pandas, Spark can read CSV files into ***dataframes***, a tabular data structure. Unlike Pandas, Spark can handle much bigger datasets but it's unable to infer the datatypes of each column.

>Note: Spark dataframes use custom data types; we cannot use regular Python types.

For this example we will use the [High Volume For-Hire Vehicle Trip Records for January 2021](https://nyc-tlc.s3.amazonaws.com/trip+data/fhvhv_tripdata_2021-01.csv) available from the [NYC TLC Trip Record Data webiste](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page). The file should be about 720MB in size.

Let's read the file and create a dataframe:

```python
df = spark.read \
    .option("header", "true") \
    .csv('fhvhv_tripdata_2021-01.csv')
```
* `read()` reads the file.
* `option()` contains options for the `read` method. In this case, we're specifying that the first line of the CSV file contains the column names.
* `csv()` is for readinc CSV files.

You can see the contents of the dataframe with `df.show()` (only a few rows will be shown) or `df.head()`. You can also check the current schema with `df.schema`; you will notice that all values are strings.

We can use a trick with Pandas to infer the datatypes:
1. Create a smaller CSV file with the first 1000 records or so.
1. Import Pandas and create a Pandas dataframe. This dataframe will have inferred datatypes.
1. Create a Spark dataframe from the Pandas dataframe and check its schema.
    ```python
    spark.createDataFrame(my_pandas_dataframe).schema
    ```
1. Based on the output of the previous method, import `types` from `pyspark.sql` and create a `StructType` containing a list of the datatypes.
    ```python
    from pyspark.sql import types
    schema = types.StructType([...])
    ```
    * `types` contains all of the available data types for Spark dataframes.
1. Create a new Spark dataframe and include the schema as an option.
    ```python
    df = spark.read \
        .option("header", "true") \
        .schema(schema) \
        .csv('fhvhv_tripdata_2021-01.csv')
    ```

You may find an example Jupiter Notebook file using this trick [in this link](../5_batch_processing/04_pyspark.ipynb).

_[Back to the top](#)_

### Partitions

_[Video Source](https://www.youtube.com/watch?v=r_Sf6fCB40c&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=50)_

A ***Spark cluster*** is composed of multiple ***executors***. Each executor can process data independently in order to parallelize and speed up work.

In the previous example we read a single large CSV file. A file can only be read by a single executor, which means that the code we've written so far isn't parallelized and thus will only be run by a single executor rather than many at the same time.

In order to solve this issue, we can _split a file into multiple parts_ so that each executor can take care of a part and have all executors working simultaneously. These splits are called ***partitions***.

We will now read the CSV file, partition the dataframe and parquetize it. This will create multiple files in parquet format.

>Note: converting to parquet is an expensive operation which may take several minutes.

```python
# create 24 partitions in our dataframe
df = df.repartition(24)
# parquetize and write to fhvhv/2021/01/ folder
df.write.parquet('fhvhv/2021/01/')
```

You may check the Spark UI at any time and see the progress of the current job, which is divided into stages which contain tasks. The tasks in a stage will not start until all tasks on the previous stage are finished.

When creating a dataframe, Spark creates as many partitions as CPU cores available by default, and each partition creates a task. Thus, assuming that the dataframe was initially partitioned into 6 partitions, the `write.parquet()` method will have 2 stages: the first with 6 tasks and the second one with 24 tasks.

Besides the 24 parquet files, you should also see a `_SUCCESS` file which should be empty. This file is created when the job finishes successfully.

Trying to write the files again will output an error because Spark will not write to a non-empty folder. You can force an overwrite with the `mode` argument:

```python
df.write.parquet('fhvhv/2021/01/', mode='overwrite')
```

The opposite of partitioning (joining multiple partitions into a single partition) is called ***coalescing***.




