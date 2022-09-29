using System.Net.Http.Json;

namespace Demo;

public class Demo1
{
    // Todo, remove this! We should be using a config file for local
    private static readonly string[] _backendSettings = new[] { "backend1", "backend2", "backend3" };
    private readonly (string Name, string Url)[] _backends;
    private readonly HttpClient _backendClient;
    public Demo1()
    {
        _backends = _backendSettings
                        .Select(x => (Name: x, Url: Environment.GetEnvironmentVariable(x) ?? string.Empty))
                        .Where(x => !string.IsNullOrWhiteSpace(x.Url))
                        .ToArray();
        _backendClient = new HttpClient();
    }

    // In demo 1, we call each API individually as part of the Address Change POST
    public async Task<string> AddressChangeRequest(AddressChange change)
    {
        if (_backends.Length < 1)
        {
            await Task.Delay(5000);
            return "Local Test: OK (No backends found)";
        }

        foreach ((string Name, string Url) in _backends)
        {
            Console.WriteLine("Calling " + Name);
            using var resp = await _backendClient.PostAsJsonAsync(Url, change);
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
}