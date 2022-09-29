#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    try
    {
        var change = await ReadFromJsonAsync<AddressChange>(req);
        log.LogInformation($"Backend 1 - Processing address change for user {change.UserId}");
        log.LogInformation($"Backend 1 - Address updated for user {change.UserId}");
        return new OkObjectResult("Backend 1 - Normal - Ok");
    }
    catch (Exception e)
    {
        log.LogError(e, "Unable to process address change");
        return new BadRequestResult();
    }
}

private static async Task<T> ReadFromJsonAsync<T>(HttpRequest req)
{
    using (StreamReader streamReader =  new  StreamReader(req.Body))
    {
        string json = await streamReader.ReadToEndAsync();
        return JsonConvert.DeserializeObject<T>(json);
    }
}

public class AddressChange
{
	public Guid UserId {get;set;}
	public DateTimeOffset RequestDate {get;set;}
	public Dictionary<string, string> Request {get;set;}
}