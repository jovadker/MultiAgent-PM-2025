using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

using Microsoft.Agents.AI;
using Azure.AI.OpenAI;
using Azure.Identity;
using OpenAI;
using ModelContextProtocol.Server;

namespace McpAzureFunction
{
    public class Program
    {
        public static void Main(string[] args)
        {
           
            var host = new HostBuilder().ConfigureFunctionsWorkerDefaults()
                .ConfigureServices(services =>
                {
                    // Register MCP server services
                    services.AddMcpServer()
                        .WithTools<McpAzureFunction.Tools.TranslateTool>()
                        .WithTools<McpAzureFunction.Tools.MathTool>();
                })
                .Build();
                
            host.Run();
        }
    }
}