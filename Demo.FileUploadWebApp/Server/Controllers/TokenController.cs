using Demo.FileUploadWebApp.Shared;

using Azure;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Azure.Storage.Sas;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Storage;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Demo.FileUploadWebApp.Server.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TokenController : ControllerBase
    {
        private readonly ILogger<TokenController> _logger;
        private readonly IConfiguration _config;

        public TokenController(ILogger<TokenController> logger, IConfiguration config)
        {
            _logger = logger;
            _config = config;
        }

        [HttpGet]
        public BlobConnectionInfo Get()
        {
            var policy = new Microsoft.Azure.Storage.SharedAccessAccountPolicy();
            policy.SharedAccessExpiryTime = DateTimeOffset.UtcNow.AddMinutes(10);
            policy.Permissions = SharedAccessAccountPermissions.Write | SharedAccessAccountPermissions.List | SharedAccessAccountPermissions.Create | SharedAccessAccountPermissions.List;
            policy.Services = SharedAccessAccountServices.Blob;
            policy.ResourceTypes = SharedAccessAccountResourceTypes.Object | SharedAccessAccountResourceTypes.Container;
            var sacs = _config["StorageAccountConnectionString"];
            var csa = CloudStorageAccount.Parse(sacs);
            var sas = csa.GetSharedAccessSignature(policy);

            return new BlobConnectionInfo() { SaS = sas, Url = csa.BlobEndpoint.AbsoluteUri};
        }

        [HttpGet("HelloWorld")]
        public string GetHelloWorld()
        {
            return "Hello World";
        }


        [HttpGet("UserSas")]
        public ContainerUserKey GetU()
        {
            // Construct the blob endpoint from the account name.
            string endpoint = "https://saasp.blob.core.windows.net";

            // Create a blob service client object using DefaultAzureCredential
            BlobServiceClient blobServiceClient = new BlobServiceClient(
                new Uri(endpoint),
                new DefaultAzureCredential());    
            
            var userDelegationKey = blobServiceClient.GetUserDelegationKey(DateTimeOffset.UtcNow, DateTimeOffset.UtcNow.AddDays(1));
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

            return new ContainerUserKey() { Key = "test", Url = "test" };
/*
            var userDelegationKey = blobServiceClient.GetUserDelegationKey(DateTimeOffset.UtcNow, DateTimeOffset.UtcNow.AddDays(1));

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

            return new ContainerUserKey() { Key = sasToken, Url = containerClient.Uri.AbsoluteUri };
*/
        }
    }
}
