#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Web.Http;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    try
    {
        var change = await ReadFromJsonAsync<AddressChange>(req);
        log.LogInformation($"Backend 3 - Processing address change for user {change.UserId}");
        await Task.Delay(5000);
        log.LogError("Backend 3 has crashed!");
        return new StatusCodeResult(500);
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