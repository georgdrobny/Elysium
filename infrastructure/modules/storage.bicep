@description('Unique String for all public names')
@maxLength(4)
@minLength(4)
param salt string = take(uniqueString(resourceGroup().id), 4)

param location string = resourceGroup().location

param tags object = {}

param namePrefix string = 'instst'
var instanceStorageAccountName = toLower('${namePrefix}${salt}')
var instanceStorageConfig = {
  accountType: 'Standard_RAGRS'
  kind: 'StorageV2'
  accessTier: 'Hot'
  minimumTlsVersion: 'TLS1_2'
  supportsHttpsTrafficOnly: true
  allowBlobPublicAccess: true
  allowSharedKeyAccess: true
  allowCrossTenantReplication: true
  defaultOAuth: false
  networkAclsBypass: 'AzureServices'
  networkAclsDefaultAction: 'Allow'
  keySource: 'Microsoft.Storage'
  encryptionEnabled: true
  keyTypeForTableAndQueueEncryption: 'Account'
  infrastructureEncryptionEnabled: false
  isContainerRestoreEnabled: false
  isBlobSoftDeleteEnabled: false
  isContainerSoftDeleteEnabled: false
  changeFeed: false
  isVersioningEnabled: false
  isShareSoftDeleteEnabled: false
}

resource instanceStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: instanceStorageAccountName
  location: location
  properties: {
    accessTier: instanceStorageConfig.accessTier
    minimumTlsVersion: instanceStorageConfig.minimumTlsVersion
    supportsHttpsTrafficOnly: instanceStorageConfig.supportsHttpsTrafficOnly
    allowBlobPublicAccess: instanceStorageConfig.allowBlobPublicAccess
    allowSharedKeyAccess: instanceStorageConfig.allowSharedKeyAccess
    allowCrossTenantReplication: instanceStorageConfig.allowCrossTenantReplication
    defaultToOAuthAuthentication: instanceStorageConfig.defaultOAuth
    networkAcls: {
      bypass: instanceStorageConfig.networkAclsBypass
      defaultAction: instanceStorageConfig.networkAclsDefaultAction
      ipRules: []
    }
    encryption: {
      keySource: instanceStorageConfig.keySource
      services: {
        blob: {
          enabled: instanceStorageConfig.encryptionEnabled
        }
        file: {
          enabled: instanceStorageConfig.encryptionEnabled
        }
        table: {
          enabled: instanceStorageConfig.encryptionEnabled
        }
        queue: {
          enabled: instanceStorageConfig.encryptionEnabled
        }
      }
      requireInfrastructureEncryption: instanceStorageConfig.infrastructureEncryptionEnabled
    }
  }
  sku: {
    name: instanceStorageConfig.accountType
  }
  kind: instanceStorageConfig.kind
  tags: tags
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: instanceStorage
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: instanceStorageConfig.isContainerRestoreEnabled
    }
    deleteRetentionPolicy: {
      enabled: instanceStorageConfig.isBlobSoftDeleteEnabled
    }
    containerDeleteRetentionPolicy: {
      enabled: instanceStorageConfig.isContainerSoftDeleteEnabled
    }
    changeFeed: {
      enabled: instanceStorageConfig.changeFeed
    }
    isVersioningEnabled: instanceStorageConfig.isVersioningEnabled
  }
}

resource storageAccountFile 'Microsoft.Storage/storageAccounts/fileservices@2021-06-01' = {
  parent: instanceStorage
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: instanceStorageConfig.isShareSoftDeleteEnabled
    }
  }
  dependsOn: [
    storageAccountBlob
  ]
}

output blob object = storageAccountBlob
output file object = storageAccountFile
