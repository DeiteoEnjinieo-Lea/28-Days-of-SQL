import luigi
import luigi.contrib.postgres
import os
import glob
import pandas as pd
import petl as etl
from datetime import datetime, timedelta, date
from sqlalchemy import create_engine
from pyspark.sql import SparkSession
from azure.storage.blob import BlobServiceClient
import shutil

csv_file_path=f'your_file_path_here'
dwh_dir = f'your_data_warehouse_loc/global_df.csv'

# aggregate aka gather your data sources
class AggregateCSV(luigi.Task):
    # generates a current timestamp
    date_interval = luigi.DateIntervalParameter(default=date.today())
    # data output
    def output(self):
        # create a unique identifier
        return luigi.LocalTarget(f'bus_data01/agg/2026/{self.date_interval}.complete')
    # run the orchestrator
    def run(self):
        # pull csv files 
        all_files = glob.glob(os.path.join(csv_file_path, "*.csv"))
        # Create a list to store individual dataframes
        # Loop through the file paths and read each one into a pandas DataFrame
        df_list = [pd.read_csv(x) for x in all_files]
        # check for errors aka exception 
        if not df_list:
            raise Exception ("!CSV NOT FOUND!")
        # combine dataFrame of sources
        combined_df = pd.concat(df_list, axis=0, ignore_index=True)
        # take the df and turn into a pyspark Session 
        spark = SparkSession.builder.appName('LuigiAutomation').getOrCreate()
        spark_df = spark.createDataFrame(combined_df)
        # write DF to CSV,coalesce to 1 to make sure a single CSV output for PETL to read
        spark_df.coalesce(1).write.format('csv').mode('error').option("header", "true").save("temp_spark_out")
# write the final CSV file 
        combined_df.to_csv(dwh_dir,index=False)

# establish DB Connection 
class DBManager(luigi.contrib.postgres.CreateConnection):
    def __init__(self):
        # Update with your PostgreSQL credentials
        self.connection_string = "postgresql://user:password@localhost:5432/mydatabase"
        self.engine = create_engine(self.connection_string)

    def get_engine(self):
        return self.engine
        
# start ETL process using PETL lib 
class ETLTask(luigi.Task):
    ingest_chk = luigi.BoolParameter()
    date_interval = luigi.DateIntervalParameter(default=date.today())
    csv_path = luigi.Parameter(default=dwh_dir)
    
    def requires(self):
        if self.ingest_chk:
            # Dependency met by running the aggregation task
            return AggregateCSV(self.date_interval)
        else:
            #If ingest_chk is false, we verify the file exists before going any further 
            if os.path.exists(self.csv_path) and os.path.isfile(self.csv_path):
                print(f"Verified: {self.csv_path} is ready.")
                return None # No dependencies needed, proceed to run() function
            else:
                # This stops the process because the condition is not met
                print("!?!CRITICAL: File missing and ingest_chk is False. Process cannot start.!?!")
                raise Exception(f"File {self.csv_path} not found.")
    def run(self):
        db = DBManager()
        engine = db.get_engine()
        # no less than 24hrs since creation date
        yesterday = datetime.now() - timedelta(hours=24)

        # Extract: Read CSV
        src_table_csv = etl.fromcsv(self.csv_path)

        # Transform: Add submissiondate field
        # staging table csv
        stg_table_csv = etl.addfield(src_table_csv, 'submissiondate', datetime.now().isoformat())

        # Join: Retrieve and join with two DB tables filtered by creationdate
        # Query for tables with creationdate within 24hrs
        query = "SELECT * FROM {} WHERE creationdate >= '{}'"
        
        east_db = etl.fromdb(engine, query.format('table1', yesterday))
        west_db = etl.fromdb(engine, query.format('table2', yesterday))

        # Join CSV data with Table 1, then with Table 2 on a key identifier (e.g., 'asset_id')
        # chain the logic 
        joined = etl.join(stg_table_csv, east_db, key='asset_id')
        final_table = etl.join(joined, west_db, key='asset_id')

        # Load: Write to PostgreSQL using todb
        etl.todb(final_table, engine, 'final_output_table')

        # DoubleCheck 
        with self.output().open('w') as f:
            f.write(f"ETL Process Complete: {datetime.now()}")
            
    def output(self):
        # Luigi requires an output to track completion
        return luigi.LocalTarget('task_complete.marker')

# final step; migrating to Azure Cloud DWH storage
# ---  Final Azure Upload Task ---
class UploadToAzure(luigi.Task):
    """
    Final step: Depends on ETLTask.
    Uploads the resulting CSV to Azure Blob Storage.
    """
    ingest_chk = luigi.BoolParameter()
    csv_path = luigi.Parameter(default=dwh_dir)

    def requires(self):
        # Enforces UploadToAzure to wait for ETLTask to finish
        return ETLTask(ingest_chk=self.ingest_chk)

    def run(self):
        # Azure Blob Storage Info
        connection_string = "your_azure_storage_connection_string"
        container_name = "warehouse-staging"
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        blob_client = blob_service_client.get_blob_client(container=container_name, blob="final_etl_output.csv")

        # Upload the verified file
        with open(self.csv_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)
            print(f"Successfully uploaded {self.csv_path} to Azure.")

        #CLEANUP TASK - clear out temp Pyspark dir
        if os.path.exists("temp_spark_out"):
            shutil.rmtree("temp_spark_out")

        # Optional: Trigger Azure Synapse COPY command here using AzureDBManager().engine
        with self.output().open('w') as f:
            f.write(f"Azure Upload Complete at {datetime.now()}")
            
        # Luigi Verification 
    def output(self):
        return luigi.LocalTarget('azure_upload_success.marker')


# Instatiate and Run the Automated Workflow 
if __name__ == '__main__':
    # Automatically triggers the final task, which pulls the rest of the chain
    luigi.run(['UploadToAzure', '--ingest-chk'])





   