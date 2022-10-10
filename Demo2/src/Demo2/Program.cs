using System.Text.Json;
using Azure.Messaging.ServiceBus;
using Azure.Core;
using Azure.Identity;
using Demo;
using System.Net.Http.Json;

string serviceBusNamespace = Utils.GetEnvironmentVariable("sb-namespace");
string serviceBusQueue = Utils.GetEnvironmentVariable("sb-queue");
(string Name, string Url)[] backends = new (string Name, string Url)[] {
	("backend1", Utils.GetEnvironmentVariable("backend1")),
	("backend2", Utils.GetEnvironmentVariable("backend2")),
};

HttpClient backendClient = new HttpClient();

#if DEBUG
TokenCredential credential = new DefaultAzureCredential();
#else
TokenCredential credential = new ManagedIdentityCredential();
#endif

ServiceBusClient sbc = new(serviceBusNamespace, credential);
ServiceBusSender sender = sbc.CreateSender(serviceBusQueue);
ServiceBusProcessor processor = sbc.CreateProcessor(serviceBusQueue);
processor.ProcessMessageAsync += RecieveMessageAsync;
processor.ProcessErrorAsync += error =>
{
	Console.WriteLine("ProcessErrorAsync");
	Console.Error.WriteLine(error.Exception);
	return Task.CompletedTask;
};

await processor.StartProcessingAsync();
new Frontend().Run(args, AddressChangeRequest);
await processor.StopProcessingAsync();

// In demo 2, we offload to a Service Bus, then process call each API individually as part of the Address Change POST
async Task<string> AddressChangeRequest(AddressChange change)
{
	await sender.SendMessageAsync(new ServiceBusMessage(JsonSerializer.Serialize(change)));
	return "Address update submitted.";
}

Task RecieveMessageAsync(ProcessMessageEventArgs message)
{
	string json = message.Message.Body.ToString();
	AddressChange change = JsonSerializer.Deserialize<AddressChange>(json) ?? throw new Exception("Null Deserialize of AddressChange");

	return ProcessAddressChange(change);
}

async Task ProcessAddressChange(AddressChange change)
{
	foreach ((string Name, string Url) in backends)
	{
		Console.WriteLine("Calling " + Name);

		using var resp = await backendClient.PostAsJsonAsync(Url, change);

		resp.EnsureSuccessStatusCode();
		string body = await resp.Content.ReadAsStringAsync();
		Console.WriteLine(Name + ": " + body);
	}
}