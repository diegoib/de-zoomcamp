from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials

@task(retires=3)
def extract_from_gcs(color: str, year: int, month: int) -> Path:
    '''Download trip data from GCS'''
    gcs_path = f'data/{color}/{color}_tripdata_{year}-{month:02}.parquet'
    gcs_block = GcsBucket.load('zoom-gcs')
    gcs_block.get_directory(from_path=gcs_path, local_path=f'../data/')
    return Path(f'../data/{gcs_path}')

@task()
def transform(path: Path) -> pd.DataFrame:
    '''Data cleaning example'''
    df = pd.read_parquet(path)
    print('pre:missing passenger count: {}'.format(df['passenger_count'].isin([0]).sum()))
    df['passenger_count'] = df['passenger_count'].fillna(0)
    print('post:missing passenger count: {}'.format(df['passenger_count'].isin([0]).sum()))
    return df

@task()
def write_bq(df: pd.DataFrame) -> None:
    '''Write DataFrame to BigQuery'''

    #to load the credentials
    gcp_credentials_block = GcpCredentials.load('zoom-gcp-creds')

    #First, we had to have created a table in GCP to be able to load data
    df.to_gbq(
        destination='dezoomcamp.rides',
        project_id='PROJECT_NAME_IN_GCP',
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chuncksize=500_000,
        if_exists='append'
    )
    


@flow()
def etl_gcs_to_bq():
    '''Main ETL flow to load data into Big Query'''
    color='yellow'
    year=2021
    month=1

    path = extract_from_gcs(color, year, month)
    df = transform(path)
    write_bq(df)


if __name__ == "__main__":

    etl_gcs_to_bq()