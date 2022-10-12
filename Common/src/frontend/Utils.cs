namespace Demo;

public class Utils
{
	private static readonly string[] _backendSettings = new[] { "backend1", "backend2", "backend3" };
	public static string GetEnvironmentVariable(string name)
	{
		string? value = Environment.GetEnvironmentVariable(name);
		if (!string.IsNullOrWhiteSpace(value)) return value;
		throw new Exception("Unable to read env var " + name);
	}

	public static (string Name, string Url)[] GetBackendsFromEnvVars()
	=> _backendSettings
		.Select(x => (Name: x, Url: Environment.GetEnvironmentVariable(x) ?? string.Empty))
		.Where(x => !string.IsNullOrWhiteSpace(x.Url))
		.ToArray();
}
