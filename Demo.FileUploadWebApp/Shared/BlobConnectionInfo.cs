using System;
using System.Collections.Generic;
using System.Text;

namespace Demo.FileUploadWebApp.Shared
{
    public class BlobConnectionInfo
    {
        public string Url { get; set; }
        public string SaS { get; set; }
    }

    public class ContainerUserKey
    {
        public string Url { get; set; }
        public string Key { get; set; }
    }
}
