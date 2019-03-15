using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using MongoDB.Driver;

namespace ServiceB
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            var client = new MongoClient(Environment.GetEnvironmentVariable("MONGO_CONNECTION_STRING"));

            string databases = null;
            Task.Run(async () => {
                IList<string> databaseList = new List<string>();
                await client.ListDatabases().ForEachAsync(db => {
                    databaseList.Add(db.GetValue("name").AsString);
                });
                databases = String.Join(',', databaseList);
            }).Wait();

            app.Run(async (context) =>
            {
                await context.Response.WriteAsync("Hello from service B on " + Environment.MachineName + " with databases " + databases + Environment.NewLine);
            });
        }
    }
}
