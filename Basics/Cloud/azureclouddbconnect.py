import urllib.parse
import os 

from azure.identity import DefaultAzureCredential
# this is an example of how to connect PostgreSQL to the Azure cloud via Azure Database for PostgreSQL
# Ive only used the public IP when dealing with Azure, no Passwordless or Tokenization
# NOT INTENDED FOR PUBLIC USAGE

# database connector
def get_connection_uri():

    # READ URI parameters from the env
    dbhost = os.environ['DBHOST']
    dbname = os.environ['DBNAME']
    dbuser = urllib.parse.quote(os.environ['DBUSER'])
    sslmode = os.environ['SSLMODE']

# NOTE: Use Passwordless auth via DefaultAzureCredential. Be careful, DefaultAzureCredential() gets evoked every call
# Use tokenization instead of this method in production!
credential = DefaultAzureCredential()

# to receive a token from MS Entra ID, use call get_token() then add it as the PW in the URI
password = credential.get_token("https://ossrdbms-aad.database.windows.net/.default").get_token

dbi_uri = f"postgresql://{dbuser}:{password}@{dbhost}/{dbname}?sslmode={sslmode}"
return dbi_uri

"""
To complete this you need to login to the Azure Portal, search for and select your Azure Database for PostgreSQL
flexible server instance aka object name 
On the server's Overview page, copy the FQSN aka fully qualified server name ex. <my-server-name>.postgres.database.azure.com
On the left menu, under Security, hit Authentication. Make sure your account is listed under MS Entra Admins
    if not, see Configure MS Entra integration on the server - Passwordless Only via Microsoft

To make everything simple, use a requirements txt file
python -m pip install -r requirements.txt

Make sure to set your env var! DBHOST, DBNAME, DBUSER, SSLMODE

"""