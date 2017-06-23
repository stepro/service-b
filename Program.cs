using System;
using System.Reflection;
using System.IO;
using System.Threading;
using Microsoft.AspNetCore.Hosting;

namespace ServiceB
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = new WebHostBuilder()
                .UseKestrel()
                .UseContentRoot(Directory.GetCurrentDirectory())
                .UseIISIntegration()
                .UseUrls("http://*:80")
                .UseStartup<Startup>()
                .Build();

            host.Run();
        }
    }
}
