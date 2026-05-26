# Azure CLI Cheat Sheet

## Authentication

```bash
az login
az login --tenant <tenant-id>
az account show
az account list --output table
az account set --subscription <subscription-id>
```

## Resource Groups

```bash
az group list --output table
az group show --name <resource-group>
az group create --name <resource-group> --location <region>
az group delete --name <resource-group> --yes --no-wait
```

## Azure Kubernetes Service (AKS)

```bash
az aks list --output table
az aks show --resource-group <rg> --name <cluster>
az aks get-credentials --resource-group <rg> --name <cluster>
az aks get-credentials --resource-group <rg> --name <cluster> --admin
az aks nodepool list --resource-group <rg> --cluster-name <cluster> --output table
az aks nodepool scale --resource-group <rg> --cluster-name <cluster> --name <nodepool> --node-count <count>
az aks browse --resource-group <rg> --name <cluster>
```

## Azure Container Registry (ACR)

```bash
az acr list --output table
az acr repository list --name <registry> --output table
az acr repository show-tags --name <registry> --repository <repo> --output table
az acr login --name <registry>
az acr build --registry <registry> --image <image:tag> .
```

## Azure Key Vault

```bash
az keyvault list --output table
az keyvault secret list --vault-name <vault> --output table
az keyvault secret show --vault-name <vault> --name <secret>
az keyvault secret set --vault-name <vault> --name <secret> --value <value>
az keyvault certificate list --vault-name <vault> --output table
```

## Virtual Machines

```bash
az vm list --output table
az vm show --resource-group <rg> --name <vm>
az vm start --resource-group <rg> --name <vm>
az vm stop --resource-group <rg> --name <vm>
az vm restart --resource-group <rg> --name <vm>
az vm deallocate --resource-group <rg> --name <vm>
az vm list-ip-addresses --output table
```

## Networking

```bash
az network vnet list --output table
az network nsg list --output table
az network nsg rule list --nsg-name <nsg> --resource-group <rg> --output table
az network public-ip list --output table
az network lb list --output table
```

## App Service

```bash
az webapp list --output table
az webapp show --resource-group <rg> --name <app>
az webapp restart --resource-group <rg> --name <app>
az webapp log tail --resource-group <rg> --name <app>
az webapp deployment list-publishing-profiles --resource-group <rg> --name <app>
```

## Azure Monitor and Logs

```bash
az monitor metrics list --resource <resource-id> --metric <metric-name>
az monitor activity-log list --resource-group <rg> --output table
az monitor log-analytics workspace list --output table
```

## Azure Policy

```bash
az policy assignment list --output table
az policy definition list --output table
az policy state list --resource-group <rg> --output table
```

## General Tips

```bash
az <command> --help
az find "<search-term>"
az interactive
az --output table
az --output json
az --output tsv
```