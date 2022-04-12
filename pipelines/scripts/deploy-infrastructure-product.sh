#!/bin/bash
LOCATION=$1
PRODUCT=$2
ENV=$3

DEPLOYMENT_FILE=infrastructure/products/$PRODUCT/main.bicep
PARAMETER_FILE=environments/$ENV/infrastructure/parameters.json

az bicep upgrade
az deployment sub validate \
    --template-file $DEPLOYMENT_FILE \
    --location $LOCATION \
    --parameters @$PARAMETER_FILE

az deployment sub create \
    --template-file $DEPLOYMENT_FILE \
    --location $LOCATION \
    --parameters @$PARAMETER_FILE