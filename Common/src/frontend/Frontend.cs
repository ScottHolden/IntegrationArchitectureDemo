﻿using Microsoft.AspNetCore.Mvc;

namespace Demo;

public class Frontend
{
	public void Run(string[] args, Func<AddressChange, Task<string>> addressChangeFunc)
	{
		var builder = WebApplication.CreateBuilder(args);

		string? appInsights = Environment.GetEnvironmentVariable("ApplicationInsights_ConnectionString");
		if (!string.IsNullOrWhiteSpace(appInsights)) 
		{
			builder.Services.AddApplicationInsightsTelemetry(x => {
				x.ConnectionString = appInsights;
			});
		}

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