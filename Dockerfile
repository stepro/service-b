FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
EXPOSE 80
WORKDIR /app

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY ["service-b.csproj", "."]
RUN dotnet restore "service-b.csproj"
COPY . .
RUN dotnet publish "service-b.csproj" -c Release -o /app

FROM base
COPY --from=build /app .
ENTRYPOINT ["dotnet", "service-b.dll"]