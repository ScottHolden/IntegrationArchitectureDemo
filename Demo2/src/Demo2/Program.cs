using Demo;
new Frontend().Run(args, AddressChangeRequest);

// In demo 1, we offload to a Service Bus, then process call each API individually as part of the Address Change POST
async Task<string> AddressChangeRequest(AddressChange change)
{
	return "Ok";
}

async Task ProcessAddressChange(AddressChange change)
{
}