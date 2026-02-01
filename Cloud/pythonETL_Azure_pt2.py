# this encompasses the Transform and Load Process now called Bronze/Silver
import pandas as pd
import io
import os
# import Class 
from pythonETL_Azure import AzureBlobManager
# ... (AzureBlobManager class here) ...
class AzureBlobManager:
    def __init__(self, connection_string):
        self.service_client = BlobServiceClient.from_connection_string(connection_string)

    def get_or_create_container(self, container_name):
        try:
            return self.service_client.create_container(container_name)
        except ResourceExistsError:
            return self.service_client.get_container_client(container_name)
# THE IN-MEMORY FLOW
    def process_and_upload(self, container, local_path):
        # 1. T - TRANSFORM (Before it hits the cloud)
        print("Transforming data in memory...")
        for chunk in pd.read_csv(local_path, chunksize=50000):
            df_clean = chunk.dropna().copy() # Example: remove empty rows, makes a new copy
        
        # 2. L - LOAD (The 'In-Memory' trick)
        # Instead of 'open(file, "rb")', we create a virtual file in RAM
        buffer = io.BytesIO()
        df_clean.to_csv(buffer, index=False)
        buffer.seek(0) # Go back to the start of the virtual file
        # Send the virtual file to your class method
        blob_client = self.service_client.get_blob_client(container, "cleaned_data.csv")
        blob_client.upload_blob(buffer, overwrite=True)
        print("Cleaned data pushed to Silver Layer.")

# Call the Functions
if __name__ == "__main__":
    # the variables
    conn_str = os.getenv('AZURE_STORAGE_CONNECTION_STRING')
    azure_manager = AzureBlobManager(conn_str)
    data_container = "raw-data-storage-brnze02012026"
    
    azure_manager.get_or_create_container(data_container)
    azure_manager.process_and_upload(data_container, "test_file_1.xml")
    azure_manager.process_and_upload(data_container,"test_file_2.csv")

