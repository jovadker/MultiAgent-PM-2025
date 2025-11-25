using System.ComponentModel;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Mcp;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.Agents.AI;
using OpenAI;
using Azure.AI.OpenAI;
using Azure.Identity;

namespace McpAzureFunction.Tools;

public class TranslateTool
{
    private readonly ILogger<TranslateTool> _logger;
    private readonly IConfiguration _configuration;
    private readonly AIAgent _agent;

    public TranslateTool(ILogger<TranslateTool> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;

        var endpoint = _configuration["AZURE_OPENAI_ENDPOINT"] ?? "https://aifoundry-stocktrading.openai.azure.com";
        var modelName = _configuration["AZURE_OPENAI_MODEL"] ?? "DeepSeek-V3.1";

        _agent = new AzureOpenAIClient(
                new Uri(endpoint),
                new DefaultAzureCredential(new DefaultAzureCredentialOptions { TenantId = "9b7dd4f7-a403-4500-afad-77b33b78b1d8" }))
                .GetChatClient(modelName).CreateAIAgent(instructions: "You are a professional translator. Translate text accurately while preserving meaning, tone, and context. Respond ONLY with the translated text, nothing else.", name: "Translator");
        
    }

    [Function("TranslateTool")]
    [Description("Translates text from one language to another using AI Agent")]
    public async Task<string> Translate(
        [McpToolTrigger("TranslateTool", "Translates text from one language to another using AI Agent")]
        ToolInvocationContext context,
        [McpToolProperty("text", "The text to translate", true)] string text,
        [McpToolProperty("targetLanguage", "The target language code (e.g., 'en', 'es', 'fr', 'de')", true)] string targetLanguage,
        [McpToolProperty("sourceLanguage", "The source language code (optional, auto-detect if not specified)", false)] string? sourceLanguage = null)
    {
        _logger.LogInformation("Translating text to {TargetLanguage}", targetLanguage);
        
        var userPrompt = sourceLanguage != null
            ? $"Translate the following text from {sourceLanguage} to {targetLanguage}:\n\n{text}"
            : $"Translate the following text to {targetLanguage}:\n\n{text}";

        // Collect all chunks into a single result
        var result = new System.Text.StringBuilder();
        await foreach (var update in _agent.RunStreamingAsync(userPrompt))
        {
            result.Append(update.ToString());
        }
        
        return result.ToString();
    }

    [Function("GetSupportedLanguages")]
    [Description("Gets the list of commonly supported languages for translation")]
    public Task<string> GetSupportedLanguages(
        [McpToolTrigger("GetSupportedLanguages", "Gets the list of commonly supported languages for translation")]
        ToolInvocationContext context)
    {
        try
        {
            _logger.LogInformation("Retrieving supported languages");

            // Common languages supported by most translation services
            var languages = new[]
            {
                new { code = "en", name = "English" },
                new { code = "es", name = "Spanish" },
                new { code = "fr", name = "French" },
                new { code = "de", name = "German" },
                new { code = "it", name = "Italian" },
                new { code = "pt", name = "Portuguese" },
                new { code = "ru", name = "Russian" },
                new { code = "ja", name = "Japanese" },
                new { code = "ko", name = "Korean" },
                new { code = "zh", name = "Chinese" },
                new { code = "ar", name = "Arabic" },
                new { code = "hi", name = "Hindi" },
                new { code = "nl", name = "Dutch" },
                new { code = "pl", name = "Polish" },
                new { code = "tr", name = "Turkish" }
            };

            return Task.FromResult(JsonSerializer.Serialize(new { languages }, new JsonSerializerOptions { WriteIndented = true }));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving supported languages");
            return Task.FromResult(JsonSerializer.Serialize(new { error = ex.Message }));
        }
    }
}