FROM microsoft/aspnetcore:2 AS base
EXPOSE 80
WORKDIR /app

FROM microsoft/aspnetcore-build:2 AS build
WORKDIR /src
COPY service-b.csproj .
RUN dotnet restore service-b.csproj
COPY . .

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish --no-restore -c $BUILD_CONFIGURATION -o /app

FROM base AS release
COPY --from=publish /app .
CMD ["dotnet", "service-b.dll"]
