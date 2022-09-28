using System.Net;
public static HttpResponseMessage Run(HttpRequestMessage req, TraceWriter log)
{
    return req.CreateResponse(HttpStatusCode.OK, "Backend 1 - Normal - Ok");
}