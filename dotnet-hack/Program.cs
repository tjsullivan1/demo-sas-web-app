using Azure;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Azure.Storage.Sas;
using System;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        // Construct the blob endpoint from the account name.
        string endpoint = $"https://saasp.blob.core.windows.net";

        // Create a blob service client object using DefaultAzureCredential
        BlobServiceClient blobServiceClient = new BlobServiceClient(
            new Uri(endpoint),
            new DefaultAzureCredential());    

        var userDelegationKey = await blobServiceClient.GetUserDelegationKeyAsync(DateTimeOffset.UtcNow, DateTimeOffset.UtcNow.AddDays(1));

        var containerClient = blobServiceClient.GetBlobContainerClient("upload");

        var sasBuilder = new BlobSasBuilder()
        {
            BlobContainerName = containerClient.Name,
            ExpiresOn = DateTimeOffset.UtcNow.AddDays(1),
            StartsOn = DateTimeOffset.UtcNow
        };

        // Specify the necessary permissions
        sasBuilder.SetPermissions(BlobSasPermissions.Read | BlobSasPermissions.Write);

        var sasToken = sasBuilder.ToSasQueryParameters(userDelegationKey, blobServiceClient.AccountName).ToString();

        Console.WriteLine(sasToken);
    }
}