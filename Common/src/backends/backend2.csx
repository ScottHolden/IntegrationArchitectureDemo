using System.Net;
using System.Threading.Tasks;
public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    await Task.Delay(30000);
    return req.CreateResponse(HttpStatusCode.OK, "Backend 2 - Slow - Ok");
}