FROM microsoft/dotnet:sdk AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app

FROM microsoft/dotnet:runtime
EXPOSE 80
WORKDIR /app
COPY --from=build /app .
CMD ["dotnet", "service-b.dll"]
