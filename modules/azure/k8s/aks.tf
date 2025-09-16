# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "random_pet" "prefix" {}

# provider "azurerm" {
#   features {}
# }

resource "azurerm_resource_group" "default" {
  name     = var.project_name
  location = var.azure_region
  tags = {
    environment = var.project_name
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = var.project_name
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.project_name}-k8s"

  default_node_pool {
    name            = var.project_name
    node_count      = var.azure_node_count
    vm_size         = var.azure_vm_size
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  # role_based_access_control {
  #   enabled = true
  # }

  tags = {
    environment = "${var.project_name}"
  }
}
