# Analytics Engineering

## Table of contents
- [Basic concepts](#basic_-concepts) 
    - [Analytics Engineering Basics](#analytics-engineering-basics)

## Basic concepts
### Analytics Engineering Basics

As the _data domain_ has developed over time, new tools have been introduced that have changed the dynamics of working with data:

1. Massively parallel processing (MPP) databases
    * Lower the cost of storage 
    * BigQuery, Snowflake, Redshift...
1. Data-pipelines-as-a-service
    * Simplify the ETL process
    * Fivetran, Stitch...
1. SQL-first / Version control systems
    * Looker...
1. Self service analytics
    * Mode...
1. Data governance

The introduction of all of these tools changed the way the data teams work as well as the way that the stakeholders consume the data, creating a gap in the roles of the data team. Traditionally:

* The ***data engineer*** prepares and maintains the infrastructure the data team needs.
* The ***data analyst*** uses data to answer questions and solve problems (they are in charge of _today_).
* The ***data scientist*** predicts the future based on past patterns and covers the what-ifs rather than the day-to-day (they are in charge of _tomorrow_).

However, with the introduction of these tools, both data scientists and analysts find themselves writing more code even though they're not software engineers and writing code isn't their top priority.  Data engineers are good software engineers but they don't have the training in how the data is going to be used  by the business users.

The ***analytics engineer*** is the role that tries to fill the gap: it introduces the good software engineering practices to the efforts of data analysts and data scientists. The analytics engineer may be exposed to the following tools:
1. Data Loading (Stitch...)
1. Data Storing (Data Warehouses)
1. Data Modeling (dbt, Dataform...)
1. Data Presentation (BI tools like Looker, Mode, Tableau...)

This lesson focuses on the last 2 parts: Data Modeling and Data Presentation.

### ETL vs ELT

We saw the differences in chapter 2, but we revisit it.

![etl vs elt](../images/04_01_etlvselt.png)

The first approach, the ETL, is going to take longer to implement because first we have to transform that data. But this also means that we are going to have more stable and compliant data because it is clean.  
On the other hand, the ELT, it is going to be faster and flexible, because we already have the data loaded in the data lake. This is also taking advantage of the cloud data warehousing that lowered the cost of storage and compute.

### Kimballs' Dimensional Modelling

[Ralph Kimball's Dimensional Modeling](https://www.wikiwand.com/en/Dimensional_modeling#:~:text=Dimensional%20modeling%20(DM)%20is%20part,use%20in%20data%20warehouse%20design.) is an approach to Data Warehouse design which focuses on 2 main points:
* Deliver data which is understandable to the business users.
* Deliver fast query performance.

Other goals such as reducing redundant data (prioritized by other approaches such as [3NF](https://www.wikiwand.com/en/Third_normal_form#:~:text=Third%20normal%20form%20(3NF)%20is,integrity%2C%20and%20simplify%20data%20management.) by [Bill Inmon](https://www.wikiwand.com/en/Bill_Inmon)) are secondary to these goals. Dimensional Modeling also differs from other approaches to Data Warehouse design such as [Data Vaults](https://www.wikiwand.com/en/Data_vault_modeling).

Dimensional Modeling is based around 2 important concepts:
* ***Fact Table***:
    * _Facts_ = _Measures_
    * Typically numeric values which can be aggregated, such as measurements or metrics.
        * Examples: sales, orders, etc.
    * Corresponds to a [_business process_ ](https://www.wikiwand.com/en/Business_process).
    * Can be thought of as _"verbs"_.
* ***Dimension Table***:
    * _Dimension_ = _Context_
    * Groups of hierarchies and descriptors that define the facts.
        * Example: customer, product, etc.
    * Corresponds to a _business entity_.
    * Can be thought of as _"nouns"_.
* Dimensional Modeling is built on a [***star schema***](https://www.wikiwand.com/en/Star_schema) with fact tables surrounded by dimension tables.

A good way to understand the _architecture_ of Dimensional Modeling is by drawing an analogy between dimensional modeling and a restaurant:
* Stage Area:
    * Contains the raw data.
    * Not meant to be exposed to everyone.
    * Similar to the food storage area in a restaurant.
* Processing area:
    * From raw data to data models.
    * Focuses in efficiency and ensuring standards.
    * Similar to the kitchen in a restaurant.
* Presentation area:
    * Final presentation of the data.
    * Exposure to business stakeholder.
    * Similar to the dining room in a restaurant.

_[Back to the top](#)_


## DBT

[DBT](https://www.getdbt.com/) stands for data-build-tool. It is a transformation tool that allows anyone that knows SQL to deploy analytics code following software engineering best practices like modularity, portability, CI/CD, and documentation.

![elt dbt](../images/04_02_elt_dbt.png)

After we have done the extraction and loading of the data, we are going to have a lot of raw data in our data warehouse (¿data lake?). We need to transform this data to later expose it to our stakeholders and be able to perform analysis. That transformation is going to be done with **dbt**. It not only is going to help us transform our data in the data warehouse, but also it's going to introduce the good software practices by defining a *deployment workflow*: we are going to develop our models, we are going to test and document them, and then we're going to have a deployment phase, where we are going to use version control and implement CI/CD as well.

![dbt workflow](../images/04_03_dbt_workflow.png)

Each model is:
- a sql file
- with a select statement and no DDL or DML
- a file that dbt will compile and run in our DWH

### How to use dbt?

**dbt Core** is the essence of dbt: it is an open source project that allows the data transformation. 
- this is the part of dbt that's going to build and run the project (.sql and .yml files)
- includes SQL compilation logic, macros (functions) and database adapters
- includes a CLI interface to run dbt commands locally
- open source and free to use

There is another part from dbt which is **dbt Cloud**. 
- this is a web-based IDE to develop, run and test a dbt project
- jobs orchestration
- logging and alerting
- integrated documentation
- free for individuals (one developer seat)

### How are we going to use dbt?

First, we need to create a dbt project. dbt provides an *starter project* with all the basic folders and files. There are essentially two ways to use it:
* with the **CLI**: After having installed dbt locally and setup the *profiles.yml*, run `dbt init` in the path we want to start the project to clone the starter project.
* with **dbt cloud**: After having set up the dbt cloud credentials (repo and dwh) we can start the project from the web-based IDE.

Important files:
- `dbt_project.yml`: In it we are going to be able to define global settings for our project, like name, profile (this is the setting thta is going to configure which databse is bdt going to be using to run this project)

When we create the **starter project**, dbt is going to provide us the basic folders and files that we are going to need, which includes some example models. One of the important files for setting up our project is *dbt_project.yml*.

We need to create a cloud account in this [link](https://www.getdbt.com/signup/), and follow this [instructions](https://docs.getdbt.com/docs/cloud/manage-access/set-up-bigquery-oauth) to set up BigQuery OAuth to connect to the data warehouse. We can also follow this [tutorial](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_4_analytics_engineering/dbt_cloud_setup.md) to set up the BigQuery service and credentials y GCP.