# Day 2: Read a folder of CSVs
import pandas as pd 
import glob 
import pyodbc
from pathlib import Path
import os 
import dask.dataframe as dd
import petl as etl 

# folder path for src 
path='path/to/your/folder'
csv_files=glob.iglob(os.path.join(path,".csv")) # takes the file path and combines with file ext

#read csv and merge 
# you can enforce dtype pd.concat((pd.read_csv(f, dtype=str)
df=pd.concat((pd.read_csv(f) for f in all_files),ignore_index=True, sort=False)

#looping thru multiple CSV
directory=PATH('path/to/your/folder')
dfs=[]

#loop
for file_path in directory.glob('*.csv'):
    temp_df = pd.read_csv(file_path)
    temp_df.columns = temp_df.columns.str.strip().str.lower()
    temp_df['src_file']=file_path.name # Adds a column with the filename
    dfs.append(temp_df)

#combine df
complete_df=pd.concat(dfs,ignore_index=True)# dont use the index 

#Modernize version - huge amount of csv
ddf = dd.read_csv(f"{path}/*.csv")
# df.compute() converts it back to a standard Pandas DataFrame if needed
dask_df=ddf.compute()
print(dask_df)

# Modernizing my ETL workflow -- use to use PETL & Pandas for ingestion and cleaning 
# Now will switch out with Dask => Dask PETL Workflow

src_df = dd.read_csv(f"{path}/*.csv") # Use Dask to point to the entire folder (lazy load)

# create a function to clean a single partition of data to stop from crashing 
def clean_with_petl(pandas_df):
    #convert partition to PETL
    table = etl.fromdataframe(pandas_df)

    # Apply your PETL cleaning logic
    table = etl.rename(table, {'old_name': 'new_name'})
    table = etl.convert(table, 'amount', float)

    # Convert back to Pandas for Dask to handle
    return etl.todataframe(table)

# Map the PETL cleaning across all Dask partitions in parallel
# distributed processing 
# This setup is budget distributed data pipeline
cleaned_ddf = ddf.map_partitions(clean_with_petl)

# Assuming 'cleaned_ddf' is your Dask DataFrame after the PETL transformations
staging_path = r'C:\SQLServer_Shares\Staging_Data'

#Save the result without ever loading it all into RAM
cleaned_ddf.to_csv(f'{staging_path}/clean_*.csv', index=False, single_file=False)

# WARNING! When you use etl.fromdataframe(pandas_df), make sure you're using the Pandas-compatible version of PETL.

"""
The SQL Server service account must have "Read" permissions for the folder where your CSVs are located. 
If the files are on your local machine and not the server's disk or a network share, the command will fail

"""

# setup connection to db 
# Database Connection: Bulk insert those CSVs using OPENROWSET or BULK INSERT commands.
conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=your_server;DATABASE=your_db;UID=your_uid;PWD=your_pwd')
# create cursor to interact with db
cursor.conn.cursor()

# Grab only the cleaned files from the staging area
clean_files = glob.glob(os.path.join(staging_dir, "*.csv"))

# FOR LOOP 
for f in clean_files:
    # We use BULK INSERT for raw speed
    sql = f"BULK INSERT StagingTable FROM '{f}' WITH (FORMAT='CSV', FIRSTROW=2);" # this is your query
    cursor.execute(sql)
    conn.commit()

print("Pipeline Complete: Folder cleaned and inserted.")

"""
Wipe the Staging Folder: Use shutil.rmtree() at the start of your script to ensure 
you aren't re-inserting yesterday's "clean" files.

The "Format File" trick: If your CSVs are still slightly unpredictable, you can use a BPC Format File 
with BULK INSERT to map specific CSV columns to specific SQL columns.

Permissions: Ensure the SQL Server Service Account (e.g., NT Service\MSSQLSERVER) has "Modify" permissions on the staging_dir.
"""







