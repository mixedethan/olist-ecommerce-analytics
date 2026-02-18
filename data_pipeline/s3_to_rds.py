import boto3
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import text
from io import StringIO
import os
from dotenv import load_dotenv
import psycopg2
import sys

## Let's define our globals
# load .env variables
load_dotenv()
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION = 'us-east-2a'

# track our RDS DB details
DB_HOST ='olist-db.ctkoee6m63v2.us-east-2.rds.amazonaws.com'
DB_PORT = '5432'
DB_NAME = 'postgres'
DB_USER = 'postgres'
DB_PASSWORD = os.getenv('DB_PASSWORD')

# s3 details
BUCKET_NAME = 'olist-data-3482-3050'

FILES_TO_LOAD = [ # need these to run in order to respect the database's rules (PKs, FKs, Cardinality)
    # first upload the independent tables
    ('olist_geolocation_dataset.csv', 'staging_geolocation'),
    ('product_category_name_translation.csv', 'staging_category_translation'),

    # next we upload the parent tables (these must exist before orders and items)
    ('olist_customers_dataset.csv', 'staging_customers'),
    ('olist_sellers_dataset.csv', 'staging_sellers'),
    ('olist_products_dataset.csv', 'staging_products'),

    # next the main transactional table (depends on customers)
    ('olist_orders_dataset.csv', 'staging_orders'),

    # children tables
    ('olist_order_items_dataset.csv', 'staging_items'),
    ('olist_order_payments_dataset.csv', 'staging_payments'),
    ('olist_order_reviews_dataset.csv', 'staging_reviews')
    
]

## Now we need to connect to our two AWS interfaces

# connect to our S3 buckets 
s3 = boto3.client('s3',
    aws_access_key_id = AWS_ACCESS_KEY_ID,
    aws_secret_access_key = AWS_SECRET_ACCESS_KEY,
)

response = s3.list_buckets()

# prints all the buckets (only one)
print('Buckets:')
for bucket in response['Buckets']:
    print(f"* {bucket['Name']}")

# now lets connect to our DB
engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

def initialize_database() -> None:
    """
    initialize_database: Runs the 'olist_architecture.sql' file located in ./sql in order to drop the tables if they exist, and then
    reinitialize the database.
    """
    print('Clearing and preparing the RDS PostgreSQL Database...\n')
    architecture_fp = './sql/00_olist_architecture.sql'

    try:
        with engine.begin() as con:
            with open(architecture_fp) as f:
                con.execute(text(f.read()))
    except Exception as e:
        print(f'Failed to initialize DB. Exception: {e}')
        sys.exit(1)

    
def load_data(filename: str, tablename: str) -> bool:
    """
    load_data: takes in a filename and its respective tablename, downloads that csv from an S3 bucket,
    then converts it to a pd.DataFrame and uploads it to an RDS database with the table name tablename
    """

    print(f'\nDownloading {filename} from S3...')
    response = s3.get_object(Bucket=BUCKET_NAME, Key="olist-data/" + filename)
    
    df = pd.read_csv(response['Body'])

    if tablename == "staging_products":
        df = df.rename(columns={
            "product_name_lenght": "product_name_length",
            "product_description_lenght": "product_description_length",
        })

    print(f'Found rows: {len(df)}')
    print(f'Attaching to table: {tablename}')

    # write to RDS
    try:
        print(f'Attempting to push {tablename} to RDS database...')
        df.to_sql(
                name=tablename,
                con=engine,
                schema='staging',
                if_exists='append',
                index=False)
        print(f'Succesfully pushed: {tablename}')
        return True
    except Exception as e:
        print(f'Unable to push CSV to RDS database, exceptions: {e}')
        return False

    
if __name__ == '__main__':
    # if name == main:

    print('\n' + ('=' * 10) + 'Beginning Ingestion Pipeline' + ('=' * 10))

    initialize_database()

    pushed = 0 

    for filename, tablename in FILES_TO_LOAD:
        if load_data(filename, tablename):
            pushed += 1
        else:
            print(f"Couldn't download {filename} and upload it to the RDS DB.")
            sys.exit(1)

    print(f'Number of tables pushed: {pushed}') # should be 9
    print(('=' * 10) + 'Completed Ingestion Pipeline!' + ('=' * 10))
    