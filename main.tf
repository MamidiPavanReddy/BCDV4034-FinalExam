
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "" 
}

resource "azurerm_resource_group" "aks" {
  name     = "aks-lab"
  location = "Canada Central"
}

resource "azurerm_kubernetes_cluster" "FI" {
  name                = "aks-lab-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "akslab"

  default_node_pool {
    name       = "default"
    node_count = 1  # Reduced to 1 node to fit quota
    vm_size    = "Standard_D2as_v4"  # 1 vCPU, 1GB RAM - fits your quota
  }

  identity {
    type = "SystemAssigned"
  }

 
  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled        = true
    file_driver_enabled        = true
    snapshot_controller_enabled = true
  }


  # Enable RBAC
  role_based_access_control_enabled = true
  
  # Kubernetes version (using latest supported non-LTS version)
  # Remove this line to use the default latest supported version
  # kubernetes_version = "1.28.5"
}

# Output the cluster credentials
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

# Output the System Assigned Identity details
output "system_assigned_identity_principal_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "system_assigned_identity_tenant_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
}