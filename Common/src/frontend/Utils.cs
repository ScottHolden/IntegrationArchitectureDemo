namespace Demo;

public class Utils
{
	public static string GetEnvironmentVariable(string name)
	{
		string? value = Environment.GetEnvironmentVariable(name);
		if (!string.IsNullOrWhiteSpace(value)) return value;
		throw new Exception("Unable to read env var " + name);
	}
}
