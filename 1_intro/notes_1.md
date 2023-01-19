# Basics and Setup

## Table of contents
- [Architecture](#architecture) 
- [GCP](#gcp)
- [Docker and Postgres](#docker-and-postgres)
    - [Docker basic concepts](#docker-basic-concepts)
    - [Running Postgres in a container](#running-Postgres-in-a-container)
    - [Ingesting data into Postgres](#ingesting-data-into-postgres)
    - [Connecting pgAdmin and Postgres](#connecting-pgadmin-and-postgres)
    - [Dockerizing the Ingestion Script](#dockerizing-the-ingestion-script)
    - [Using Docker Compose](#using-docker-compose)


## Architecture

This is the architecture to work along in the course.

![architecture diagram](../images/01_01_arch.jpg)


## Docker and Postgres

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

Now, let's put it into a container. This container is going to have a python 3.9 layer, pandas, we can do it through a `dockerfile`. A dockerfile is a file that specifies what is going to be inside the container. It needs be called dockerfile.

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

Let's run a cli client, from our computer (not from inside the container) for accesing the database. For that purpouse, we are going to use `pgcli`, and can be install with `pip`:

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


### Connecting pgAdmin and Postgres

There is a more convinient way of writng queries to the database rather than using `pgcli`. There is another tool with a graphical user inteface, [`pgAdmin`](https://www.pgadmin.org/). We can install it, but since we are using docker, we can make it simpler and run it in a container. We can run it with:

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \ # User name
    -e PGADMIN_DEFAULT_PASSWORD="root" \ # User password
    -p 8080:80 \ # Host port : Container port, we dont use host port 80 to avoid conflicts
    dpage/pgadmin4
```
Now, we can access pgAdmin through the web broser by typing: `localhost:8080`
If we try to connect to the postgres database we are running in another container, we have to specify the host machine. If we specify "localhost", **pgAdmin** is going to look inside its container, so won't be able to find **postgres**. That is because we need to create a `network` in docker to make available 2 containers to interact between them. 

To create a **docker network** we can run:

```bash
docker network create pg-network # pg-network is the name of the network we are creating
```

And then run the docker container specifying the name of the network we want to use, and the name that the container is going to have inside the network. This last name is the one we are going to use to refer to the container when we connect two or more containers. 

```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:13

docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4
```

Once we are inide **pgAdmin**, to connect to the postgres database, we make right click in _Server_ > _Register_ > _Server..._ 

![steps](../images/01_03_pgadmin.png)


### Dockerizing the Ingestion Script

Next, we will convert the later jupyter notebook into a script. So with that we can put it inside a container and run it.  
To export the notebook into a script, we can use the `nbconvert` functionality of jupyter:

```bash
jupyter nbconvert --to=script ipload-data-ipynb
```

We clean the output script and add a few new lines of code. We are going to use the library [`argparse`](https://docs.python.org/es/3/library/argparse.html). The complete script can be found in [this link](src/ingest_data.py).

To execute the script, we can run:

```bash
python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_data \
    --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz" 
```

But, it is better if we put it inside a docker container. For that we need to create a `dockerfile`.

```dockerfile
FROM python:3.9

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2

WORKDIR /app
COPY ingest_data.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]
```

And build it with:

```bash
docker build -t taxi_ingest:v001 .
```
To run the container created, and taking as input the same parameters, we can run with `docker run`. We have to be aware to specify the network created and the host name:

```bash
docker run -it \
    --network=pg-network \
    taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_data \
    --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz" 
```

In this way, when we run the container, we are running the script (as it is declared in the dockerfile that the entrypoint is **["python", "ingest_data.py"]**). Once the script finishes, the container will stop.


### Using Docker Compose
[`Docker Compose`](https://docs.docker.com/compose/) is a tool for defining and running multiple containers at the same time. With this tool we can run at the same time all the containers that we want, preventign to have to run each container at a time from the command line.  
First, we need to download and install the tool. Then we need to create a docker-compose file where we specify the containers and specifications we need to run. The file needs to be called `docker-compose.yaml`, and its format is `yaml`. We don't need to specify a **network** as docker compose will take care of that.
Some **Docker Compose** commands:
* `docker-compose` shows all different commands we can run
* `docker-compose up` will run the containers specify in the docker-compose.yaml file of the working directory
    * `docker-compose up -d` run in detached mode
* `docker-compose down` stop the containers

The `docker compose file` is like:
```yaml
services:
 # name of the container 1
 pgdatabase: # name of the container
   # image we are using
   image: postgres:13
   # environment variables we need to run
   environment:
     - POSTGRES_USER=root 
     - POSTGRES_PASSWORD=root 
     - POSTGRES_DB=ny_taxi
   # to persist data on the host machine
   volumes:
     - $ ../../ny_taxi_postgres_data:/var/lib/postgresql/data
   # port mapping
   ports:
     - 5432:5432
 # name of the container 2 ...
 pgadmin:
   image: dpage/pgadmin4
   environment:
     - PGADMIN_DEFAULT_EMAIL=admin@admin.com
     - PGADMIN_DEFAULT_PASSWORD=root
   ports:
     - 8080:80
```

## GCP and Terraform

### Google Cloud Platform
Google Cloud Platform (GCP) is a combination of cloud computing services offered by Google. It includes a range of hosted services for compute, sotrage and application development that run on Google hardware. Some of the topics of these services are: Compute, Management, Networking, Storage & Databases, Big Data, Identity & Security, and Machine Learning.

GCP generally works in terms of projects. You can create a new project or use and existing one which comes as default.

### Terraform
[Terraform](https://www.terraform.io/) is an open source tool by HashiCorp, taht lets provision infrastructure resources with declarative configuration files. These resources can be VMs, containers, storage... Terraform uses an IaC ([Infrasturcture-as-Code](https://www.wikiwand.com/en/Infrastructure_as_code)) approach, which supports devops best practices for change management. It is like a git version control for infrastructure.

### Local Setup for Terraform and GCP
- Terraform: [Installation](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- GCP: steps

  1. Create a *project*, everything in GCP works inside projects. Choose a *project name* and a *project id*. This last one must be unique across the entire GCP environment.
  1. On the panel on the left, go to *IAM & Admin > Service Accounts > Create Service Account*: A **service account** is an account that you create for a service, as the name suggests, and a service could be anything (like a data pipeline, web service...), and everything this service need, would de configured here in this service account. For example, if the service needs access to the cloud storage, we will grant access to it here.
      1. Choose a *name* and a *service id*, this one does not need to be unique across GCP
      1. *Description* can be anything
      1. *Role*, choose Viewer for now to begin with. Click on *Done*
      1. With the *service account* created, the see that there are no *keys* created. Click on three dots under *Actions > Manage keys > Add Key > Create new key > JSON > Create*. With this last step, we download the json file into our local computer.
  1. Install the [*GCP SDK*](https://cloud.google.com/sdk/docs/install?hl=es-419), which is a CLI tool, that lets insteract with the cloud services. 
      - Check the version
      ```bash
      gcloud -v
      ```
  1. Set a environment variable to point to the downloaded GCP aut-keys, and login:
      ```bash
      export GOOGLE_APPLICATION_CREDENTIALS="<path/yo/your/service-account-authkeys>.json"

      gcloud auth application-default login
      ```
      - A popup window will appear and ask you to authenticate the local cli into the google cloud platform account. This is an OAuth authentication, but there are other ways to authenticate (for example for when you are in a virtual machine that does not have a web browser).