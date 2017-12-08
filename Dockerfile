FROM microsoft/aspnetcore:2 AS base
EXPOSE 80
WORKDIR /app

FROM microsoft/aspnetcore-build:2 AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .

FROM build AS publish
RUN dotnet publish -c Release -o /app

FROM base AS release
COPY --from=publish /app .
CMD ["dotnet", "service-b.dll"]
