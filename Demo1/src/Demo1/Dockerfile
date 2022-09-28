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
COPY "Demo1/src/Demo1/Demo1.csproj" "Demo1/src/Demo1/Demo1.csproj"
RUN dotnet restore "Demo1/src/Demo1/Demo1.csproj"
COPY 'Demo1/src/Demo1' "Demo1/src/Demo1"
RUN dotnet build "Demo1/src/Demo1/Demo1.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Demo1/src/Demo1/Demo1.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
# wwwroot fix for publish
COPY --from=common /src/Common/src/frontend/wwwroot ./wwwroot
ENTRYPOINT ["dotnet", "Demo1.dll"]