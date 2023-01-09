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

Whys should we care about docker?
- Local experiments
- Integration tests (CI/CD)
- Reproducibility
- Running pipelines on the cloud (AWS Batch, Kubernetes jobs)
- Spark
- Serverless (AWS Lambda, Google functions)

(To use Linux on Windows, we can use MINGW. It comes with Git when it is installed in Windows)

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