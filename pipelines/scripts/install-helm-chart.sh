#!/bin/bash
ACR=$1
CHART_VERSION=$2
PRODUCT=$3
ENVIRONMENT=$4
RELEASE_NAME=$5
NAMESPACE=$6

echo ACR=$ACR CHART_VERSION=$CHART_VERSION PRODUCT=$PRODUCT ENVIRONMENT=$ENVIRONMENT RELEASE_NAME=$RELEASE_NAME NAMESPACE=$NAMESPACE
helm version
export HELM_EXPERIMENTAL_OCI=1
USER_NAME="00000000-0000-0000-0000-000000000000"
PASSWORD=$(az acr login --name $ACR --expose-token --output tsv --query accessToken)
helm registry login $ACR.azurecr.io --username $USER_NAME --password $PASSWORD
helm upgrade $RELEASE_NAME oci://$ACR.azurecr.io/helm/elysium \
    --install \
    --version $CHART_VERSION \
    --namespace $NAMESPACE \
    --create-namespace \
    -f environments/$ENVIRONMENT/values.yaml