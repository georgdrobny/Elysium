param acrName string
param aks object

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: acrName
}

var AcrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var KubeletObjectId = any(aks.properties.identityProfile.kubeletidentity).objectId

resource aks_acr_pull 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' =  {
  scope: acr // Use when specifying a scope that is different than the deployment scope
  name: '${guid(aks.id, 'Acr' , AcrPullRole)}'
  properties: {
    roleDefinitionId: AcrPullRole
    principalType: 'ServicePrincipal'
    principalId: KubeletObjectId
  }
}
