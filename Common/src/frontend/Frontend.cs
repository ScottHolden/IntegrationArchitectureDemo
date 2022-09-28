namespace Frontend;

public class Frontend
{
	public void Run(string[] args)
	{
		var app = WebApplication.CreateBuilder(args).Build();

		app.UseStaticFiles();

		app.MapPost("submit", async () =>
		{

		});

		app.MapGet("data", async () => "Hello");

		app.Run();
	}
}
