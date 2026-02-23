# creating 1TB of data using one of my fav generators: FAKER
# when you dont have acess to a dataset you can use FAKER to generate all kinds of data
# to populate whatever you need, this script does that and moves it to Azure DataLake Account

import pandas as pd 
from faker import Faker
from pyspark.sql import SparkSession
# import os

# Use Azure credentials, Service principal or Account Key
# Pull this information from a secure Key Vault

storage_options = {
    'account_name': 'azure_storage_account_name',
    'account_key': 'azure_secret_account_key'
}
# instatiate Faker, make sure to set Region
fake = Faker('en-US')

# create the function to generate 1TB of data 
def generate_to_azure(batch_id,records_per_batch=100000):
    # create the fake data
    data_list = []
    
    for _ in range(records_per_batch):
        # Create a dictionary representing one row in our "Database"
        record = {
            "transaction_id": str(uuid.uuid4()),            # Unique primary key
            "customer_name": fake.name(),                   # Random full name
            "email": fake.email(),                          # Email
            "amount": fake.pydecimal(left_digits=3, right_digits=2, positive=True), # Price
            "transaction_date": fake.date_time_this_year(), # Timestamp within the current year
            "city": fake.city(),                            # City for geographic analysis
            "product_id": fake.bothify(text='PROD-####')   # Custom format like 'PROD-1234'
        }
        data_list.append(record)
    
    # Convert the list of dictionaries into a Pandas DataFrame
    # This prepares the data for "Loading" into a file format.
    # always Parquet for compression
    df = pd.DataFrame(data_list)
    azure_path = f"abfss://my-container@my-account.dfs.core.windows.net/raw_data/batch_{batch_id}.parquet"

# Save directly to the Cloud 
# Pass 'storage_options' var so pandas has permission to write to Azure
    df.to_parquet(azure_path, storage_options=storage_options, engine='pyarrow')
    print(f"Uploaded batch {batch_id} to Azure Data Lake")

# Note: No os.makedirs() needed here!
# run the function 
generate_to_azure(1)

# Complete the rest of orchestration via Azure portal
