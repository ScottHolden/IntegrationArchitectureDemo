using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;

namespace Demo;

public class Frontend
{
	public void Run(string[] args, Func<AddressChange, Task<string>> addressChangeFunc)
	{
		var builderOptions = new WebApplicationOptions
		{
#if DEBUG
			ContentRootPath = Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly()?.Location),
#endif
			Args = args
		};    
		var builder = WebApplication.CreateBuilder(builderOptions);

		if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("APPLICATIONINSIGHTS_CONNECTION_STRING")))
		{
			Console.WriteLine("Using application insights");
			builder.Services.AddApplicationInsightsTelemetry();
			builder.Services.AddSingleton<ITelemetryInitializer>(new RoleNameTelemetryInitializer("FrontEnd"));
		}


		var app = builder.Build();
		var logger = app.Services.GetRequiredService<ILogger<Frontend>>();
		logger.LogInformation("FrontEnd starting...");

		app.UseDefaultFiles();
		app.UseStaticFiles();

		app.MapPost("submit", async (AddressChangeRequest changeRequest) =>
		{
			// Todo: Validate changeRequest
			AddressChange addressChange = new(Guid.NewGuid(), DateTimeOffset.UtcNow, changeRequest);
			return await addressChangeFunc(addressChange);
		});

		app.Run();
	}
}

public record AddressChangeRequest(
	string AddressLine1, 
	string AddressLine2, 
	string City,
	string State,
	int Postcode,
	string Country
);
public record AddressChange(
	Guid UserId,
	DateTimeOffset RequestDate,
	AddressChangeRequest Request
);

public class RoleNameTelemetryInitializer : ITelemetryInitializer
{
	private readonly string _roleName;
	public RoleNameTelemetryInitializer(string roleName)
	{
		_roleName = roleName;
	}
	public void Initialize(ITelemetry telemetry)
	{
		telemetry.Context.Cloud.RoleName = _roleName;
	}
}