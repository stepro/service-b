FROM microsoft/aspnetcore:2 AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/aspnetcore-build:2 AS develop
RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip \
 && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .

FROM develop AS publish
RUN dotnet publish -c Release -o /app

FROM base AS release
COPY --from=publish /app .
CMD ["dotnet", "service-b.dll"]
