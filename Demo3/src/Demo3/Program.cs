using System.Text.Json;
using Azure.Messaging.ServiceBus;
using Azure.Core;
using Azure.Identity;
using Demo;

string serviceBusNamespace = GetEnvironmentVariable("sb-namespace");
string serviceBusTopic = GetEnvironmentVariable("sb-topic");

#if DEBUG
TokenCredential credential = new DefaultAzureCredential();
#else
TokenCredential credential = new ManagedIdentityCredential();
#endif

ServiceBusClient sbc = new(serviceBusNamespace, credential);
ServiceBusSender sender = sbc.CreateSender(serviceBusTopic);

new Frontend().Run(args, AddressChangeRequest);

// In demo 3, we publish an event to a Service Bus Topic
async Task<string> AddressChangeRequest(AddressChange change)
{
	await sender.SendMessageAsync(new ServiceBusMessage(JsonSerializer.Serialize(change)));
	return "Address successfully updated.";
}

static string GetEnvironmentVariable(string name)
{
	string? value = Environment.GetEnvironmentVariable(name);
	if (!string.IsNullOrWhiteSpace(value)) return value;
	throw new Exception("Unable to read env var " + name);
}