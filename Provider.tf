terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "existing_aks" {
  name                = "aks-alb-poc"
  resource_group_name = "rg-aks-alb-poc"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.existing_aks.kube_config[0].cluster_ca_certificate)
  }
}