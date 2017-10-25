FROM microsoft/aspnetcore-build:2
EXPOSE 80
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
CMD ["dotnet", "run"]
