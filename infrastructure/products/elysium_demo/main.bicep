
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

var aksResourceName = '${namePrefix}${salt}' 
module aks '../../aks/main.bicep' = {
  name: 'aks'
  scope: newRG
  params: {
    tags: tags
    resourceName: aksResourceName
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

resource acrRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: acrResourceGroup
}

module acrPullRoleDeployment '../../modules/acrroles.bicep' = {
  name: 'acrPullRoleDeployment'
  scope: acrRG
  dependsOn: [
    aks
  ]
  params: {
    location: location
    acrName: acrName
    kubeletObjectId: aks.outputs.kubeletObjectId
  }
}
