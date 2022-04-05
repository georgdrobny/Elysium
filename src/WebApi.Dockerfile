# How to execute this dockerfile:
# Create intermediate build:
# $ docker build -f WebApi.Dockerfile --target build -t elysium_webapi_build .
# $ docker create --name elysium_webapi_build elysium_webapi_build
# $ docker cp elysium_webapi_build:/src .temp/src
# Now the source, build output and test results are in ./tmp-src
# Create final build
# $ docker build -t elysium_webapi_build:latest .
# Cleanup (required to run the beginning steps again)
# $ docker rm -f elysium_webapi_build

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
ENV ASPNETCORE_ENVIRONMENT="Production"
ENV ASPNETCORE_URLS="http://+:8080"
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release

WORKDIR /src

ENV PATH="$PATH:/root/.dotnet/tools" 

COPY Elysium.Library/Elysium.Library.csproj Elysium.Library/Elysium.Library.csproj
COPY Elysium.Library.Tests/Elysium.Library.Tests.csproj Elysium.Library.Tests/Elysium.Library.Tests.csproj
COPY Elysium.WebApi.Host/Elysium.WebApi.Host.csproj Elysium.WebApi.Host/Elysium.WebApi.Host.csproj

RUN dotnet restore Elysium.Library/Elysium.Library.csproj
RUN dotnet restore Elysium.Library.Tests/Elysium.Library.Tests.csproj
RUN dotnet restore Elysium.WebApi.Host/Elysium.WebApi.Host.csproj

COPY Elysium.Library Elysium.Library
COPY Elysium.Library.Tests Elysium.Library.Tests
COPY Elysium.WebApi.Host Elysium.WebApi.Host
 
RUN dotnet build -c $BUILD_CONFIGURATION Elysium.Library.Tests
RUN dotnet test --no-build --no-restore -c $BUILD_CONFIGURATION Elysium.Library.Tests --logger trx --results-directory test-results /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput="coverage"
RUN dotnet publish -o /app -c $BUILD_CONFIGURATION Elysium.WebApi.Host/Elysium.WebApi.Host.csproj

FROM runtime AS final
WORKDIR /app
COPY --from=build /app ./
CMD dotnet Elysium.WebApi.Host.dll