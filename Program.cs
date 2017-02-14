using System;
using System.Reflection;
using System.Runtime.Loader;
using System.Threading;
using Microsoft.AspNetCore.Hosting;

namespace ServiceB
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var done = new ManualResetEventSlim(false);
            using (var cts = new CancellationTokenSource())
            {
                Action shutdown = () =>
                {
                    if (!cts.IsCancellationRequested)
                    {
                        Console.WriteLine("Application is shutting down...");
                        cts.Cancel();
                    }

                    done.Wait();
                };

                var assemblyLoadContext = AssemblyLoadContext.GetLoadContext(typeof(Program).GetTypeInfo().Assembly);
                assemblyLoadContext.Unloading += context => shutdown();

                Console.CancelKeyPress += (sender, eventArgs) =>
                {
                    shutdown();
                    eventArgs.Cancel = true;
                };

                new WebHostBuilder()
                    .UseKestrel(options => {
                        options.ShutdownTimeout = TimeSpan.FromSeconds(10);
                    })
                    .UseStartup<Startup>()
                    .UseUrls("http://*:80")
                    .Build()
                    .Run(cts.Token);

                done.Set();
            }
        }
    }
}
