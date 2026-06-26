# Terraform Cheat Sheet

## Workflow Commands

```bash
# Initialize a working directory (download providers, modules)
terraform init

# Re-initialize and upgrade provider versions
terraform init -upgrade

# Validate configuration syntax
terraform validate

# Format configuration files
terraform fmt

# Format recursively
terraform fmt -recursive

# Check formatting without modifying
terraform fmt -check
```

## Plan and Apply

```bash
# Preview changes
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan for a specific variable file
terraform plan -var-file=production.tfvars

# Apply changes (interactive approval)
terraform apply

# Apply a saved plan (no approval prompt)
terraform apply tfplan

# Apply with auto-approve (use with caution)
terraform apply -auto-approve

# Apply targeting a specific resource
terraform apply -target=azurerm_resource_group.main

# Destroy all managed infrastructure
terraform destroy

# Destroy a specific resource
terraform destroy -target=azurerm_virtual_machine.web
```

## State Management

```bash
# List all resources in state
terraform state list

# Show details of a specific resource
terraform state show azurerm_resource_group.main

# Move a resource in state (rename)
terraform state mv azurerm_resource_group.old azurerm_resource_group.new

# Remove a resource from state (without destroying)
terraform state rm azurerm_resource_group.legacy

# Import existing infrastructure into state
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/my-rg

# Pull remote state to local
terraform state pull

# Push local state to remote
terraform state push

# Replace a provider in state
terraform state replace-provider hashicorp/azurerm registry.terraform.io/hashicorp/azurerm
```

## Workspace Management

```bash
# List workspaces
terraform workspace list

# Create a new workspace
terraform workspace new staging

# Switch to a workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete a workspace
terraform workspace delete staging
```

## Output and Console

```bash
# Show all outputs
terraform output

# Show a specific output
terraform output resource_group_name

# Show output in JSON format
terraform output -json

# Interactive console for expressions
terraform console
```

## Provider Configuration

```hcl
# Azure provider
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```

## Variables

```hcl
# Variable declaration (variables.tf)
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
```

```bash
# Pass variables via CLI
terraform plan -var="environment=prod" -var="instance_count=3"

# Pass variables via file
terraform plan -var-file=production.tfvars
```

## Common Patterns

### Resource with lifecycle rules

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${var.project}"
  location = var.location
  tags     = var.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["CreatedDate"]]
  }
}
```

### Data source (reference existing resources)

```hcl
data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "existing" {
  name                = "kv-shared"
  resource_group_name = "rg-shared"
}
```

### Dynamic blocks

```hcl
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
```

### Modules

```hcl
module "network" {
  source = "./modules/network"

  environment = var.environment
  location    = var.location
  vnet_cidr   = "10.0.0.0/16"
}

# Reference module outputs
resource "azurerm_kubernetes_cluster" "main" {
  # ...
  default_node_pool {
    vnet_subnet_id = module.network.subnet_id
  }
}
```

### for_each and count

```hcl
# for_each with a map
resource "azurerm_resource_group" "env" {
  for_each = toset(["dev", "staging", "prod"])
  name     = "rg-${each.key}"
  location = var.location
}

# count
resource "azurerm_managed_disk" "data" {
  count                = var.disk_count
  name                 = "disk-data-${count.index}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128
  create_option        = "Empty"
}
```

## Debugging

```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform plan

# Log to file
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform plan

# Log levels: TRACE, DEBUG, INFO, WARN, ERROR

# Show dependency graph (DOT format)
terraform graph | dot -Tpng > graph.png
```

## References

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
