FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
ENV ASPNETCORE_ENVIRONMENT="Production"
ENV ASPNETCORE_URLS="http://+:8080"
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release

WORKDIR /src

ENV PATH="$PATH:/root/.dotnet/tools" 

COPY Elysium.WebApp.Host/Elysium.WebApp.Host.csproj Elysium.WebApp.Host/Elysium.WebApp.Host.csproj

RUN dotnet restore Elysium.WebApp.Host/Elysium.WebApp.Host.csproj

COPY Elysium.WebApp.Host Elysium.WebApp.Host

RUN dotnet publish -o /app -c $BUILD_CONFIGURATION Elysium.WebApp.Host/Elysium.WebApp.Host.csproj

FROM runtime AS final
WORKDIR /app
COPY --from=build /app ./
CMD dotnet Elysium.WebApp.Host.dll