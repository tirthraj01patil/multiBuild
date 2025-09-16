# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.64.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  
  client_id     = var.appId
  client_secret = var.password
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.default.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
}
