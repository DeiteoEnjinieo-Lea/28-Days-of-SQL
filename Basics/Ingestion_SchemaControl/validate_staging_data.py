# PART2 - handle the "bad" rows in Python for logging or alerting
import pyodbc
from pyodbc import Error
import pandas as pd 

#sql_file_path = 'day06_basics.sql'
#cursor = connection.cursor()

def find_production_blockers(sql_file_path):
    connection = None
    try:
        # Connect to your database
        connection = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=your_host;'
            'DATABASE=your_db;'
            'UID=your_user;'
            'PWD=your_password'
        )

        # Read my SQL script 
        with open(sql_file_path, 'r') as file:
            sql_script = file.read()

        # Execute the script
        print(f"Executing validation script: {sql_file_path}...")

        # Load rows into a DataFrame
        df = pd.read_sql(sql_script, connection)

        if df.empty:
            print("Success: No production blockers found!")
        else:
            print(f"Warning: Found {len(df)} rows that failed SQL validation.")

         # Python-Side Verification (The "Bridge")
         # use 'errors=coerce' to turn failures into NaT/NaN for review later
            print("Running Python-side type auditing...")
            
            # Check Age (INT)
            df['Age_Check'] = pd.to_numeric(df['Raw_Age'], errors='coerce')
            
            # Check JoinDate (DATE)
            df['Date_Check'] = pd.to_datetime(df['Raw_JoinDate'], errors='coerce')
            
            # Check Balance (FLOAT/DECIMAL)
            # regex=True to handle the commas that fail in SQL!
            df['Balance_Check'] = pd.to_numeric(df['Raw_Balance'].replace({',': ''}, regex=True), errors='coerce')

            # Show the rows where Python ALSO found issues
            print(df[['Raw_Name', 'Age_Check', 'Date_Check', 'Balance_Check']])

    except (Exception, Error) as error:
        print(f"Error: {error}")

    finally:
        if connection:
            connection.close()
            print("Connection closed.")

find_production_blockers('day06_basics.sql')

'''

Previous Code Script

cursor.execute(sql_script)
# Verify dtypes frorm previous SQL SERVER script
sql_src = pd.read_sql(sql_script)

chck_dtypesNUM = pd.to_numeric(df['col'], errors='coerce')
chck_dtypesDATE = pd.to_datetime(df['col'], errors='coerce')
chck_dtypesFLOAT = df['col'].astype(float, errors='ignore')

# Find the "Bad" rows
bad_rows = cursor.fetchall()

if not bad_rows:
    print("Success: No production blockers found!")
else:
    print(f"Warning: Found {len(bad_rows)} rows that will fail.")
        for row in bad_rows:
            # Basic Python-side logging
            print(f"Row ID {row[0]} failed validation. Data: {row[1:]}")
            # catch any errors within the process
        except (Exception, Error) as error:
            print(f"Error while connecting to SQLServer: {error}")
    finally:
        if connection:
            cursor.close()
            connection.close()
            print("SQLServer connection is closed.")
# Run the function
find_production_blockers('validate_staging.sql')

'''
