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


# logic to check content of our bucket
# olist_bucket = s3.list_objects(Bucket=BUCKET_NAME)['Contents']
# print(f'\nItems in {BUCKET_NAME}:')
# for item in olist_bucket:
#     print(item['Key'])

# now lets connect to our DB
engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)



def load_data(filename, tablename):
    """
    load_data: takes in a filename and its respective tablename, downloads that csv from an S3 bucket,
    then converts it to a pd.DataFrame and uploads it to an RDS database with the table name tablename
    """

    print(f'Downloading {filename} from S3...')
    response = s3.get_object(Bucket=BUCKET_NAME, Key="olist-data/" + filename)
    
    df = pd.read_csv(response['Body'])

    print(f'Found rows: {len(df)}')
    print(f'Attaching to table: {tablename}')

    # write to RDS
    # blah blah blah

    print(f'Finished {tablename}')





if __name__ == '__main__':
    print('Beginning Ingestion Pipeline...')
    
    for filename, tablename in FILES_TO_LOAD.items():
        try:
            load_data(filename, tablename)
        except Exception as e:
            print(f"Couldn't download {filename} and upload it to the RDS DB.")
    