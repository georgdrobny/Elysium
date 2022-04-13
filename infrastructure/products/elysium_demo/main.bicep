
var salt = take(uniqueString(subscription().id, namePrefix, branch), 4)

// set the target scope for this file
targetScope = 'subscription'

@minLength(3)
@maxLength(11)
param namePrefix string

param productName string
param environmentName string
param version string
param branch string
param acrName string
param acrResourceGroup string

param location string = deployment().location
var tags =  {
  product: productName
  environment: environmentName
  version: version
  branch: branch
}

var resourceGroupName = '${namePrefix}${salt}rg'

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module storage '../../modules/storage.bicep' = {
  name: 'storage'
  scope: newRG
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
  }
}

var aksResourceName = 'aks-${namePrefix}${salt}' 
module aks '../../aks/main.bicep' = {
  name: 'aks'
  scope: newRG
  params: {
    tags: tags
    resourceName: resourceGroupName
    location: location
    agentCount: 1
    upgradeChannel: 'stable'
    agentVMSize: 'Standard_B2s'
    osDiskType: 'Managed'
    enable_aad: true
    enableAzureRBAC: true
    omsagent: true
    retentionInDays: 30
    azureKeyvaultSecretsProvider: true
    createKV: true
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-01-01' existing = {
  name: aksResourceName
  scope: newRG
}

module acrPullRole '../../modules/acrroles.bicep' = {
  name: 'acrPullRole'
  scope: resourceGroup(acrResourceGroup)
  params: {
    acrName: acrName
    aks: aksCluster
  }
}

output aksClusterId string = aksCluster.id
