using System.Net;
using System.Threading.Tasks;
public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    await Task.Delay(30000);
    return req.CreateResponse(HttpStatusCode.InternalServerError, "Backend 3 - Fail");
}