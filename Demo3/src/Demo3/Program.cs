using System.Text.Json;
using Azure.Messaging.ServiceBus;
using Azure.Core;
using Azure.Identity;
using Demo;

string serviceBusNamespace = Utils.GetEnvironmentVariable("sb-namespace");
string serviceBusTopic = Utils.GetEnvironmentVariable("sb-topic");

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