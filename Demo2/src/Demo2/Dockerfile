FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS common
WORKDIR /src
COPY "Common/src/frontend/Frontend.csproj" "Common/src/frontend/Frontend.csproj"
RUN dotnet restore "Common/src/frontend/Frontend.csproj"
COPY 'Common/src/frontend' "Common/src/frontend"
RUN dotnet build "Common/src/frontend/Frontend.csproj" -c Release

FROM common AS build
WORKDIR /src
COPY "Demo2/src/Demo2/Demo2.csproj" "Demo2/src/Demo2/Demo2.csproj"
RUN dotnet restore "Demo2/src/Demo2/Demo2.csproj"
COPY 'Demo2/src/Demo2' "Demo2/src/Demo2"
RUN dotnet build "Demo2/src/Demo2/Demo2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Demo2/src/Demo2/Demo2.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
# wwwroot fix for publish
COPY --from=common /src/Common/src/frontend/wwwroot ./wwwroot
ENTRYPOINT ["dotnet", "Demo2.dll"]