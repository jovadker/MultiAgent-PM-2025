using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Mcp;
using System.ComponentModel;

namespace McpAzureFunction.Tools
{
    public class MathTool
    {
        [Function("Add")]
        [Description("Adds two numbers together")]
        public int Add(
            [McpToolTrigger("Add", "Adds two numbers together")]
            ToolInvocationContext context,
            [McpToolProperty("a", "First number", true)] 
            int a,
            [McpToolProperty("b", "Second number", true)]
            int b)
        {
            return a + b;
        }

        [Function("Greet")]
        [Description("Gets a greeting message for a given name")]
        public string Greet(
            [McpToolTrigger("Greet", "Gets a greeting message for a given name")] 
            ToolInvocationContext context,
            [McpToolProperty("name", "Name to greet", false)] string name)
        {
            return $"Hello, {name}! Welcome to MCP on Azure Functions.";
        }

        [Function("CalculateRectangleArea")]
        [Description("Calculates the area of a rectangle")]
        public double CalculateRectangleArea(
            [McpToolTrigger("CalculateRectangleArea", "Calculates the area of a rectangle")]
            ToolInvocationContext context,
            [McpToolProperty("width", "Width of the rectangle", true)] double width,
            [McpToolProperty("height", "Height of the rectangle", true)] double height)
        {
            return width * height;
        }
    }
}