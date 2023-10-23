import os
import sys
import time
import click
from .parseFihr import parse_fihr
from .download import BCDADownloader
from .config import CONFIG
from .snowflake import write_sql
import pandas as pd

def log(str, err=False):
    if err:
        click.secho(str, err=True, fg='red')
    else:
        click.secho(str)

@click.group()
def cli():
    pass

@cli.group()
def dataset():
    pass

@dataset.command(help="Download data from the BCDA API")
def download():
    log('Downloading data from BCDA API')
    downloader = BCDADownloader()
    downloader.authenticate()
    downloader.patient_export()
    while True:
        status = downloader.try_download_files()
        if status['status'] == 'Done':
            break
        else:
            log(f"Export status: {status['status']}")
            time.sleep(5)

@dataset.command(help="Parse the downloaded data to csv")
def parse():
    config_path = "config"
    config_files = ["Coverage", "ExplanationOfBenefits", "Patient"]
    os.makedirs(os.path.join('data', CONFIG.DATASET_NAME, "csv"), exist_ok=True)
    for f in config_files:
        parse_fihr(f"{config_path}/config{f}.ini", os.path.join('data', CONFIG.DATASET_NAME))

@dataset.command(help="Uploads the csv data to snowflake")
def upload():
    data_dir = os.path.join('data', CONFIG.DATASET_NAME, "csv")
    files = [os.path.splitext(f)[0] for f in os.listdir(data_dir)]
    for f in files:
        log(f"Uploading {f}")
        df = pd.read_csv(os.path.join(data_dir, f"{f}.csv"), low_memory=False)
        write_sql(df, f'{CONFIG.DATASET_NAME}_{f}', if_exists='replace')

if __name__ == '__main__':
    cli()