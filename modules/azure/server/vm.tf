# Generate SSH key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.project_server}.pem"
  file_permission = "0600"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_server}-rg"
  location = var.location_server
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_server}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_server}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.project_server}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group (open all inbound ports)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project_server}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.project_server}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine
locals {
  custom_data = templatefile("${path.module}/user-data.sh", {
    deploy_postgres = tostring(var.deploy_postgres_azure)
    deploy_redis    = tostring(var.deploy_redis_azure)
    deploy_kafka    = tostring(var.deploy_kafka_azure)
    deploy_rabbitmq = tostring(var.deploy_rabbitmq_azure)
    deploy_neo4j    = tostring(var.deploy_neo4j_azure)
  })
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.project_server
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.size_server
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = var.project_server
  disable_password_authentication = true

  custom_data = base64encode(local.custom_data)
}
