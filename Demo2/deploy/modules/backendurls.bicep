param backends array
output backendUrls array = [for backend in backends: {
  name: backend.name
// For demo purposes:
#disable-next-line outputs-should-not-contain-secrets
  value: '${backend.functionUrl}?code=${listkeys(backend.functionId, '2022-03-01').default}'
}]
