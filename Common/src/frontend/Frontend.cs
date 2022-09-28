namespace Demo;

public class Frontend
{
	public void Run(string[] args, Func<AddressChange, Task<string>> addressChange)
	{
		var app = WebApplication.CreateBuilder(args).Build();

		app.UseDefaultFiles();
		app.UseStaticFiles();

		app.MapPost("submit", async () =>
		{
			var change = new AddressChange(Guid.NewGuid(), "abc");
			return await addressChange(change);
		});

		app.Run();
	}
}

public record AddressChange(Guid userId, string address);