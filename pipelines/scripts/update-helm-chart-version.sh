#!/bin/bash

ACR=$1
CHART_VERSION=$2
APP_VERSION=$3

echo ACR=$ACR CHART_VERSION=$CHART_VERSION APP_VERSION=$APP_VERSION

helm version
export HELM_EXPERIMENTAL_OCI=1
helm package charts/elysium --version $CHART_VERSION --app-version $APP_VERSION --debug
USER_NAME="00000000-0000-0000-0000-000000000000"
PASSWORD=$(az acr login --name $ACR --expose-token --output tsv --query accessToken)
helm registry login $ACR.azurecr.io --username $USER_NAME --password $PASSWORD
helm push elysium*.tgz oci://$ACR.azurecr.io/helm