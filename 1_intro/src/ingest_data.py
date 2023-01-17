#!/usr/bin/env python
# coding: utf-8

import os
import pandas as pd
from time import time
from sqlalchemy import create_engine

import argparse


def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url

    print('inside function')
    print(user, password, table_name)

    csv_name = 'output.csv'
    os.system(f"wget {url} -O {csv_name}.gz")
    # I need to add this sentence as the file is zipped
    os.system(f"gzip -d {csv_name}.gz")

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    df_iter = pd.read_csv(f'{csv_name}', iterator=True, chunksize=100000)
    df = next(df_iter)


    df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
    df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append')

    while True:
        try: 
            t_start = time()
            
            df = next(df_iter)
            
            df['tpep_pickup_datetime'] = pd.to_datetime(df['tpep_pickup_datetime'])
            df['tpep_dropoff_datetime'] = pd.to_datetime(df['tpep_dropoff_datetime'])

            df.to_sql(name=table_name, con=engine, if_exists='append')
            
            t_end = time()
            
            print('Inserted another chunk..., took %.3f seconds' % (t_end - t_start))
        
        except StopIteration:
            print('Ingestion completed')
            break

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description = 'Import CSV data to Postgres')

    parser.add_argument('--user', help='user name for postgres')  
    parser.add_argument('--password', help='password for postgres') 
    parser.add_argument('--host', help='host name for postgres') 
    parser.add_argument('--port', help='user name for postgres') 
    parser.add_argument('--db', help='database name for postgres') 
    parser.add_argument('--table_name', help='name of the table where we will write the results to') 
    parser.add_argument('--url', help='url of the csv file') 

    args = parser.parse_args()
    main(args)


