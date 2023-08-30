from azure.identity import DefaultAzureCredential
from azure.storage.blob import (
    BlobServiceClient,
    ContainerClient,
    BlobClient,
    BlobSasPermissions,
    UserDelegationKey,
    generate_container_sas,
    generate_blob_sas
)
import datetime


def request_user_delegation_key(blob_service_client: BlobServiceClient) -> UserDelegationKey:
    # Get a user delegation key that's valid for 1 day
    delegation_key_start_time = datetime.datetime.now(datetime.timezone.utc)
    delegation_key_expiry_time = delegation_key_start_time + datetime.timedelta(days=1)

    user_delegation_key = blob_service_client.get_user_delegation_key(
        key_start_time=delegation_key_start_time,
        key_expiry_time=delegation_key_expiry_time
    )

    return user_delegation_key


def create_user_delegation_sas_container(container_client: ContainerClient, user_delegation_key: UserDelegationKey):
    # Create a SAS token that's valid for one day, as an example
    start_time = datetime.datetime.now(datetime.timezone.utc)
    expiry_time = start_time + datetime.timedelta(days=1)

    sas_token = generate_container_sas(
        account_name=container_client.account_name,
        container_name=container_client.container_name,
        user_delegation_key=user_delegation_key,
        permission=BlobSasPermissions(read=True),
        expiry=expiry_time,
        start=start_time
    )

    return sas_token


def main():
    # Construct the blob endpoint from the account name
    account_url = "https://saasp.blob.core.windows.net"

    #Create a BlobServiceClient object using DefaultAzureCredential
    blob_service_client = BlobServiceClient(account_url, credential=DefaultAzureCredential())
    container_client = blob_service_client.get_container_client("upload")

    user_delegation_key = request_user_delegation_key(blob_service_client)    
    print(user_delegation_key)
    sas_token = create_user_delegation_sas_container(container_client, user_delegation_key)

    print(sas_token)


if __name__ == "__main__":
    main()