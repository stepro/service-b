FROM microsoft/aspnetcore:2.0 AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/aspnetcore-build:2.0 AS build
WORKDIR /src
COPY service-b.csproj .
RUN dotnet restore service-b.csproj
COPY . .
RUN dotnet build service-b.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish service-b.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "service-b.dll"]