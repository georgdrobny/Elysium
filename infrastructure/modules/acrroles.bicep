param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: acrName
}

var AcrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
param kubeletObjectId string

resource aks_acr_pull 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' =  {
  scope: acr // Use when specifying a scope that is different than the deployment scope
  name: guid(kubeletObjectId, 'Acr' , AcrPullRole)
  properties: {
    roleDefinitionId: AcrPullRole
    principalType: 'ServicePrincipal'
    principalId: kubeletObjectId
  }
}
