import os
from dotenv import load_dotenv
from azure.storage.blob import BlobServiceClient
# error handling if a resource has been provisioned already
from azure.core.exceptions import ResourceExistsError

load_dotenv()

"""
Best Practice: Use a .env file or Environment Variable, never hardcode the passwords to your accounts
in your scripts. People can use them to login

+ Create a file named .env.
+ Inside it, put: AZURE_STORAGE_CONNECTION_STRING=your_secret_key_here.
+ In Python, use load_dotenv() to access it securely.

Action: You can install it via the PyPI dotenv page.
"""

class AzureBlobManager:
    """
    This handles file management and Azure Blob storage operations.

    """
    def __init__(self, connection_string):
        # The constructor initializes the master client once
        # connect_str = os.getenv('AZURE_STORAGE_CONNECTION_STRING') - Setup your connection 
        # blob_service_client = BlobServiceClient.from_connection_string(connect_str)
        self.service_client = BlobServiceClient.from_connection_string(connection_string)

    def get_or_create_container(self, container_name):
        """Ensures the container exists and returns the client."""
        try:
            container_client = self.service_client.create_container(container_name)
            """
            Create the container in the cloud
            
            Create a unique name for the container
            added the date for unique identifier naming convention 
            
            container_name = "raw-data-storage-brnze02012026"
            
            try:

                container_client = blob_service_client.create_container(container_name)
                print(f"Creating container: {container_name} has been created.")
            except ResourceExistsError:
                
                This prevents any error stemming from duplicate resources crashing your script
                print(f"Container '{container_name}' already exists. Please provide a different container name.")
                container_client = blob_service_client.get_container_client(container_name)
            """
            print(f"Container '{container_name}' created.")
            return container_client
        except ResourceExistsError:
            print(f"Container '{container_name}' already exists.")
            return self.service_client.get_container_client(container_name)

    def upload_file(self, container_name, local_path):
        """Handles the binary upload logic."""
        # target file name 
        # Create a blob client (Specific path for the file)
        blob_name = os.path.basename(local_path)
        blob_client = self.service_client.get_blob_client(container=container_name, blob=blob_name)
        
        # Uploading the files 
        
        print(f"Uploading {blob_name}...")
        with open(local_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)
        print("Upload successful.")

# --- HOW YOU USE IT (The 'Call' to the object) ---
if __name__ == "__main__":
    # 1. Instantiate the object once aka call it
    # INSTANTIATE (Setup your connection)
    conn_str = os.getenv('AZURE_STORAGE_CONNECTION_STRING')
    azure_manager = AzureBlobManager(conn_str)
    
    # 2. Use the object's methods as many times as you want
    # Note -- Create a unique name for the container, NO UNDERSCORES 4 Azure
    my_container = "raw-data-storage-brnze02012026"
    
    # Example: Uploading two different files using the same object
    # Once an object is created (azure_manager), can call its functions by supplying the correct args
    azure_manager.get_or_create_container(my_container)
    azure_manager.upload_file(my_container, "test_file_1.xml")
    azure_manager.upload_file(my_container, "test_file_2.csv")
