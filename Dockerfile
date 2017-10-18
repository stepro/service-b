FROM microsoft/aspnetcore:2 AS base
EXPOSE 80
WORKDIR /app

FROM microsoft/aspnetcore-build:2 AS develop
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .

FROM develop AS publish
RUN dotnet publish -c Release -o /app

FROM base
COPY --from=publish /app .
CMD ["dotnet", "service-b.dll"]
