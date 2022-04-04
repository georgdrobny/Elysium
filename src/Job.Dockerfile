FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
ENV ASPNETCORE_ENVIRONMENT="Production"

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release

WORKDIR /src

COPY Elysium.Job.Host/Elysium.Job.Host.csproj Elysium.Job.Host/Elysium.Job.Host.csproj

RUN dotnet restore Elysium.Job.Host/Elysium.Job.Host.csproj

COPY Elysium.Job.Host Elysium.Job.Host

RUN dotnet publish -o /app -c $BUILD_CONFIGURATION Elysium.Job.Host/Elysium.Job.Host.csproj

FROM runtime AS final
WORKDIR /app
COPY --from=build /app ./
CMD dotnet Elysium.Job.Host.dll