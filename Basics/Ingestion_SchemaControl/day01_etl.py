# Day 1: Python: Extract JSON from an API. 
# T-SQL: Create a "Staging" table with JSON_VALUE to parse that data into columns.
from mssql_python import connect
import requests
import json

# Connection Details
srv = 'your_server_name' # 'localhost' or '192.168.1.5'
db = 'your_db'
usr = 'your_username'
pwd = 'your_password'


# Define the API endpoint & Fetch the data
url = "https://api.github.com/events"
response = requests.get(url)

raw_json_string = None # init to prevent ReferenceErrors

# Check for errors and extract JSON
if response.status_code == 200:
    data = response.json()  
    # Decodes JSON into a Python dictionary/list
    # Convert the Python list/dict back to a string so SQL can read it
    raw_json_string = json.dumps(data)
else:
    print(f"API Error: {response.status_code}")

# Create Staging Table and Parse
# We use a variable (?) to pass the raw_json_string into SQL    
try:
    # Connection string including server and database/insert variable
    conn_str = f"Server={srv};Database={db};Encrypt=yes;User Id={usr};Password={pwd}"
    conn = connect(conn_str)
    cursor = conn.cursor()
    # similar functionality to psycopg
    # Execute the T-SQL
    sql_script = """

    -- Create a temporary place for the raw string
    IF OBJECT_ID('Staging_Users', 'U') IS NOT NULL DROP TABLE Staging_Users;
    
    -- Create the Staging Table structure
    CREATE TABLE Staging_Users (
    UserID NVARCHAR(100),
    FirstName NVARCHAR(100),
    Email NVARCHAR(255),
    City NVARCHAR(100)
    );

    -- Insert and parse data from a source table containing raw JSON strings

INSERT INTO Staging_Users (UserID, FirstName, Email, City)
SELECT id, first, email, city
FROM OPENJSON(?)
WITH (
    id NVARCHAR(100) '$.id',
    first NVARCHAR (100) '$.actor.login',
    email NVARCHAR (100) '$.email',
    city NVARCHAR (100)  '$.city'
);
 """
    cursor.execute(sql_script, (raw_json_string,))   
    conn.commit() # Important: Save changes to the DB

    print("Data successfully staged!")
    conn.close()

except Exception as e:
    print(f"Connection Failed: {e}")

"""

Here is where to find each piece of info:

1. Server Name & Database Name
Visual Check: In SSMS, the Server Name is at the very top of the Object Explorer (formatted as ServerName\InstanceName).

Database Name: Expand the Databases folder in the Object Explorer to see the list of available databases.
T-SQL Query: Run SELECT @@SERVERNAME; to get the exact server string and SELECT DB_NAME(); for the current 
database name. 

2. User ID (Login)

Find Logins: In SSMS, expand Security > Logins. This lists all valid accounts (like sa or your custom users).
Find Your Current User: Run SELECT SUSER_SNAME(); to see exactly which user you are currently logged in as. 

3. Password

Security Policy: For security, SQL Server does not store passwords in plain text; they are salted and hashed.

Resetting: If you forgot the password for a specific SQL login (like sa), you can right-click the user in 
Security > Logins, select Properties, and enter a new password.

Windows Authentication: If you are using your Windows login, you don't need a separate password in your 
Python connection string—just set Trusted_Connection=yes (for pyodbc) or similar integrated security flags

"""


