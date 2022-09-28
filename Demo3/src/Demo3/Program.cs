using Demo;
new Frontend().Run(args, AddressChangeRequest);

// In demo 3, we publish an event to a Service Bus Topic
async Task<string> AddressChangeRequest(AddressChange change)
{
	return "Ok";
}