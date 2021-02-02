using Demo.FileUploadWebApp.Shared;

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
    }
}
