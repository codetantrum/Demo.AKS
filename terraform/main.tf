# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    # This bug caused a local file stored in tf cloud to cause an error once it was changed to raw output in code
    # The following local block is the workaround suggested
    # https://discuss.hashicorp.com/t/no-resource-schema-found-for-local-file-in-terraform-cloud/34561/3
    local = {
      version = "~> 2.1"
    }
  }
  # Configure Terraform Cloud provider
  cloud {
    organization = "Omegalul"
    workspaces {
      name = "demo-AKS"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-demo" {
  name     = "rg-demo"
  location = var.resource-group-location
}

# Begin k8s cluster config
resource "azurerm_kubernetes_cluster" "k8cluster" {
  name                             = "k8cluster"
  location                         = azurerm_resource_group.rg-demo.location
  resource_group_name              = azurerm_resource_group.rg-demo.name
  dns_prefix                       = "k8s-demo"
  http_application_routing_enabled = true

  default_node_pool {
    name       = "default"
    node_count = "1"
    vm_size    = "standard_d2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "k8pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8cluster.id
  name                  = "k8spool"
  node_count            = "1"
  vm_size               = "standard_d11_v2"
}