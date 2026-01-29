import boto3
import pandas as pandas
from sqlalchemy import create_engine
from io import StringIO
import os
from dotenv import load_dotenv
import psycopg2

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

FILES_TO_LOAD = {
    'olist_orders_dataset.csv': 'staging_orders',
    'olist_customers_dataset.csv': 'staging_customers',
    'olist_order_items_dataset.csv': 'staging_items',
    'olist_products_dataset.csv': 'staging_products',
    'olist_sellers_dataset.csv': 'staging_sellers',
    'olist_geolocation_dataset.csv': 'staging_geolocation',
    'olist_order_payments_dataset.csv': 'staging_payments',
    'olist_order_reviews_dataset.csv': 'staging_reviews',
    'product_category_name_translation.csv': 'staging_category_translation'
}

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


def load_data(filename: str, tablename: str) -> None:
    """
    load_data: takes in a filename and its respective tablename, downloads that csv from an S3 bucket,
    then converts it to a pd.DataFrame and uploads it to an RDS database with the table name tablename
    """

    print(f'\nDownloading {filename} from S3...')
    response = s3.get_object(Bucket=BUCKET_NAME, Key="olist-data/" + filename)
    
    df = pd.read_csv(response['Body'])

    print(f'Found rows: {len(df)}')
    print(f'Attaching to table: {tablename}')

    # write to RDS
    try:
        print(f'Attempting to push {tablename} to RDS database...')
        df.to_sql(tablename, con=engine, if_exists='append', index=False)
    except Exception as e:
        print('Unable to push CSV to RDS database, exceptions: {e}')

    print(f'Succesfully pushed: {tablename}')


if __name__ == '__main__':
    # if name == main:
    print('Beginning Ingestion Pipeline...')
    df_list = [] 

    for filename, tablename in FILES_TO_LOAD.items():
        try:
            df_list.append(load_data(filename, tablename))
        except Exception as e:
            print(f"Couldn't download {filename} and upload it to the RDS DB.")

    print(f'Number of tables pushed: {len(df_list)}') # should be 9
    print('--- Completed Ingestion Pipeline! ---')
    