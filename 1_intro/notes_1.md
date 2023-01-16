# Basics and Setup

## Table of contents
- Architecture
- GCP + Postgres

## 1. Architecture

This is the architecture to work along in the course.

![architecture diagram](../images/01_01_arch.jpg)


## 2. GCP
Google Cloud Platform (GCP) is a combination of cloud computing services offered by Google. It includes a range of hosted services for compute, sotrage and application development that run on Google hardware. Some of the topics of these services are: Compute, Management, Networking, Storage & Databases, Big Data, Identity & Security, and Machine Learning.

GCP generally works in terms of projects. You can create a new project or use and existing one which comes as default.

## 3. Docker + Postgres

### Docker basic concepts
Docker delivers software in packages called containers, and containers are isoletd from one another.
A data pipeline is the process / service that gets in data and produces more data.

![data pipeline](../images/01_02_datapipeline.png)

Why should we care about docker?
- Local experiments
- Integration tests (CI/CD)
- Reproducibility
- Running pipelines on the cloud (AWS Batch, Kubernetes jobs)
- Spark
- Serverless (AWS Lambda, Google functions)

* To use Linux on Windows, we can use `MINGW`. It comes with Git when it is installed in Windows.

After downloading Docker, to run a container, just type:

```bash
docker run -it python:3.9
```

If we want to import pandas in a container with that image, it has not pandas incorporated, so we can run the container from bash, and then do a pip install.

```bash
docker run -it --entrypoint=bash python:3.9
pip install pandas
```
Let's create a dummy `pipeline.py` python file, that takes in one argument and prints it:

```python
import pandas as pd
import sys

print(sys.argv)

day = sys.argv[1]

print(f'job finished successfully for day = {day}')
```

Now, let's put it into a container. This container is going to have a python 3.9 layer, pandas, we can do it through a `dockerfile`.

```dockerfile
FROM python:3.9

RUN pip install pandas

WORKDIR /app
COPY pipeline.py pipeline.py

ENTRYPOINT ["bash"]
```

To convert the dockerfile into an image, in the shell we run:

```bash
docker build -t test:pandas .
```
* The image name will be `test` and the tag `pandas`. if we don't specify a tag, the default is `latest`.

And then run it with:

```bash
docker run -it test:pandas 2023-01-01
```

### Running Postgres in a container

```bash
docker run -it \
    -e POSTGRES_USER="root" \ # to run environmental variables
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \ # host_folder:container_folder
    -p 5432:5432 \ # host_port:container_port
    postgres:13
```
* enviromental variables: they can be set for the container
* volumes: a way to map folders of the host machine to a folder in the container. As Postgres is a database, we need to keep the files in a file system to save records...

Let's run a cli client for accesing the database. For that purpouse, we are going to use `pgcli`, and can be install with `pip`:

```bash
pip install pgcli
```

After installing it, we can access the postgres database in the container that is up with:

```
pgcli -h localhost -p 5432 -u root -d ny_taxi
```
* `h` is the host. As we are running it locally we can use `localhost`
* `p` is the port
* `u` is the username
* `d` is the database we want to access

We will need to introduce the password that we set when running the container.

Postgres commands:
* `\dt` to show the tables in the database
* `\d table_name` to describe the table columns and types

### Ingesting data into Postgres

To populate the database, we are going to download data from the [New York taxi data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page):

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2021-01.parquet
```
As the code follows along the old data files in `csv` format (now they are in `parquet` format), we can download them from the **DataTalksClub github repo** in this [link](https://github.com/DataTalksClub/nyc-tlc-data).

The code for ingesting the Postgres database with the downloaded data is in [`upload-data.ipynb`](src/upload-data.ipynb).