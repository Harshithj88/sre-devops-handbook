# Bicep Cheatsheet

Quick reference for Azure Bicep IaC authoring.

## CLI Commands

```bash
# Build Bicep to ARM
az bicep build --file main.bicep

# Deploy to resource group
az deployment group create \
  --resource-group rg-myapp \
  --template-file main.bicep \
  --parameters @params.bicepparam

# What-if (dry run)
az deployment group what-if \
  --resource-group rg-myapp \
  --template-file main.bicep

# Decompile ARM to Bicep
az bicep decompile --file template.json

# Validate without deploying
az deployment group validate \
  --resource-group rg-myapp \
  --template-file main.bicep

# List deployments
az deployment group list --resource-group rg-myapp -o table

# Export resource to Bicep
az bicep export --resource /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{name}
```

## Syntax Essentials

### Parameters

```bicep
@description('The Azure region for resources')
@allowed(['westus2', 'eastus2'])
param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param storageAccountName string

@secure()
param adminPassword string
```

### Variables

```bicep
var appName = 'myapp-${uniqueString(resourceGroup().id)}'
var tags = {
  environment: 'dev'
  managedBy: 'bicep'
}
```

### Resources

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  tags: tags
}
```

### Outputs

```bicep
output storageId string = storageAccount.id
output storageName string = storageAccount.name

@description('Primary blob endpoint')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
```

### Modules

```bicep
module vnet 'modules/vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    location: location
    vnetName: 'vnet-${appName}'
  }
}

// Reference module output
output subnetId string = vnet.outputs.subnetId
```

### Conditions

```bicep
param deployBastion bool = false

resource bastion 'Microsoft.Network/bastionHosts@2023-09-01' = if (deployBastion) {
  name: 'bastion-hub'
  location: location
  // ...
}
```

### Loops

```bicep
param subnets array = [
  { name: 'web', prefix: '10.0.1.0/24' }
  { name: 'app', prefix: '10.0.2.0/24' }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [for subnet in subnets: {
  name: 'nsg-${subnet.name}'
  location: location
}]
```

### Existing Resources

```bicep
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-hub'
  scope: resourceGroup('rg-networking')
}
```

## Common Patterns

### Resource Group Scope Deployment

```bash
az deployment group create -g rg-myapp -f main.bicep
```

### Subscription Scope Deployment

```bicep
targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-myapp'
  location: 'westus2'
}
```

```bash
az deployment sub create --location westus2 -f main.bicep
```

### Referencing Key Vault Secrets in Parameters

```bicep
param sqlPassword string

// In .bicepparam file:
// param sqlPassword = az.getSecret('<subscriptionId>', 'rg-secrets', 'kv-myapp', 'sql-admin-password')
```

## Linting

```bash
# Install Bicep linter rules
az bicep lint --file main.bicep

# bicepconfig.json for custom rules
```

```json
{
  "analyzers": {
    "core": {
      "rules": {
        "no-unused-params": { "level": "warning" },
        "no-unused-vars": { "level": "warning" },
        "prefer-interpolation": { "level": "warning" },
        "secure-parameter-default": { "level": "error" }
      }
    }
  }
}
```

## Useful Functions

| Function | Example |
|----------|---------|
| `uniqueString()` | `uniqueString(resourceGroup().id)` → deterministic hash |
| `resourceGroup()` | `.id`, `.name`, `.location` |
| `subscription()` | `.subscriptionId`, `.tenantId` |
| `environment()` | `.suffixes.storage`, `.authentication.loginEndpoint` |
| `loadTextContent()` | `loadTextContent('script.sh')` |
| `loadJsonContent()` | `loadJsonContent('config.json')` |
