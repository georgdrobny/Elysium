#!/bin/bash
ACR=$1
CHART_VERSION=$3
PRODUCT=$4
ENVIRONMENT=$5
RELEASE_NAME=$6
NAMESPACE=$7

echo ACR=$ACR CHART_VERSION=$CHART_VERSION APP_VERSION=$APP_VERSION
helm version
export HELM_EXPERIMENTAL_OCI=1
USER_NAME="00000000-0000-0000-0000-000000000000"
PASSWORD=$(az acr login --name $ACR --expose-token --output tsv --query accessToken)
helm registry login $ACR.azurecr.io --username $USER_NAME --password $PASSWORD
k create namespace $NAMESPACE
helm upgrade --install $RELEASE_NAME oci://$ACR_NAME.azurecr.io/helm/elysium \ 
    --version $CHART_VERSION \
    --namespace $NAMESPACE \
    --create-namespace \
    --verify \
    -f environments/$ENVIRONMENT/values.yaml