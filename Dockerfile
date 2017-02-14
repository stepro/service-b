FROM microsoft/dotnet:runtime
EXPOSE 80

WORKDIR /app
COPY out .

CMD ["dotnet", "service-b.dll"]
