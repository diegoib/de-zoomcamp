# Data Warehouse

## Table of contents
- [Basic concepts](#basic_-concepts) 
    - [Data Lake](#data-lake)
    - [ETL vs ELT](#etl-vs-elt)


## Basic concepts
### OLAP vs OLTP
- **OLTP** stands for OnLine Transaction Processing
    - *Purpose*: control and run essential business operations in real time
    - *Data updates*: short, fast updates initiated by user
    - *Databse design*: normalized databases for efficiency
    - *Space requirements: generally small if historical data is archived
- **OLAP** stands for OnLine Analytical Processing
    - *Purpose*: plan, solve problems, support decisions, discover hidden insights
    - *Data updates*: data periodically refreshed with scheduled, long-running batch jobs
    - *Database deign*: denormalized databases for analysis
    - *Space requirements*: generally large due to aggregating large datasets

|                        | OLTP                                                        | OLAP                                                               |
|------------------------|-------------------------------------------------------------|--------------------------------------------------------------------|
| **Purpose**            | control and run essential business  operations in real time | plan, solve problems, support decisions,  discover hidden insights |
| **Data updates**       | short, fast updates initiated by user                       | plan, solve problems, support decisions, discover hidden insights  |
| **Database design**    | normalized databases for efficiency                         | denormalized databases for analysis                                |
| **Space requirements** | generally small if historical data is archived              | generally large due to aggregating large datasets                  |