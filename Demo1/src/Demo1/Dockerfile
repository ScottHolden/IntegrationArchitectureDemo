ARG demoName=Demo1

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY "Common/src/frontend/Frontend.csproj" "Common/src/frontend/"
COPY "${demoName}/src/${demoName}.csproj" "${demoName}/src/"

RUN dotnet restore "${demoName}/src/${demoName}.csproj"

COPY 'Common/src/frontend' "Common/src/frontend"
COPY '${demoName}/src/' "${demoName}/src/"
RUN dotnet build "${demoName}/src/${demoName}.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "${demoName}.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "${demoName}.dll"]