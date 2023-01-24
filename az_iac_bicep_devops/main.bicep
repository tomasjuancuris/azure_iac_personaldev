/*
AZURE IaC Bicep template.
With this template you can provision the following infrastructure:
- Azure Storage Account (Hierachical Namespace ON)
- Azure Data Factory
- Azure Databricks Workspace (Premium Tier)
- Azure Key Vault
*/

// deployment scope
targetScope = 'resourceGroup'

// global parameters/variables
// resource_group_name is not used during local deployment but is present for CI/CD using Azure Devops
param resource_group_name string = 'dev_rg'
param location string = 'eastus'
param environment string = 'dev'



// storage account parameters/variables
var storageAccountName = '${environment}datalaketcdemo'

// data factory parameters/variables
var dataFactoryName = '${environment}datafactorytcdemo'

// databricks parameters/variables
var databricksName = '${environment}databrickstcdemo'
var managedResourceGroupName = 'databricks-rg-${databricksName}-${uniqueString(databricksName, resourceGroup().id)}'

// keyvault parameters/variables
var keyVaultName = '${environment}keyvaultcdemo'



// resource section


@description('StorageAccount Section')

resource storage_account 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
    isHnsEnabled: true
  }
}

@description('DataFactory Section')

resource data_factory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  properties:{
    globalParameters:{
      env: {
        type: 'String'
        value: environment
      }
    }
  }
}



@description('''
Databricks Section
- managedResourceGroup references the exclusive resource group that is needed for every
databricks deployment. This rg contains resourses used by the workspace and should not be
used for other purposes.
''')

resource databricks 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: databricksName
  location: location
  sku: {
    name: 'premium'
  }
  properties:{
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
  
  }
}


@description('KeyVault Section')

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties:{
    accessPolicies:[]
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
     }
  enabledForTemplateDeployment: true
  enableSoftDelete: true
  }
}
