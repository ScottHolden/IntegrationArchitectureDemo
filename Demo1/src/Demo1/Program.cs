using Demo;
new Frontend().Run(args, AddressChangeRequest);

// In demo 1, we call each API individually as part of the Address Change POST
async Task<string> AddressChangeRequest(AddressChange change)
{
	await Task.Delay(10000);
	return "Test time out of 10 seconds";
}