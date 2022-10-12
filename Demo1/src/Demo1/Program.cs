using System.Net.Http.Json;
using Demo;

(string Name, string Url)[] backends = Utils.GetBackendsFromEnvVars();
HttpClient backendClient = new HttpClient();

new Frontend().Run(args, ProcessAddressChange);

async Task<string> ProcessAddressChange(AddressChange change)
{
    foreach ((string Name, string Url) in backends)
    {
        Console.WriteLine("Calling " + Name);

        using var resp = await backendClient.PostAsJsonAsync(Url, change);
        
        if (resp.IsSuccessStatusCode)
        {
            string body = await resp.Content.ReadAsStringAsync();
            Console.WriteLine(Name + ": " + body);
        }
        else
        {
            Console.WriteLine(Name + " failed: " + resp.StatusCode);
            return "Address update failed on one or more backends.";
        }
    }

    return "Address successfully updated.";
}