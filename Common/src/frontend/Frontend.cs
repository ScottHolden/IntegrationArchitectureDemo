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

		builder.Services.AddSingleton(new RoleNameTelemetryInitializer("FrontEnd"));
		builder.Services.AddApplicationInsightsTelemetry();
		

		var app = builder.Build();

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
	private readonly string? _roleName;
	public RoleNameTelemetryInitializer(string roleName)
	{
		_roleName = roleName;
	}
	public void Initialize(ITelemetry telemetry)
	{
		telemetry.Context.Cloud.RoleName = _roleName;
	}
}