resource "azurerm_resource_group" "polkadot-aks" {
  name     = "polkadot-${var.cluster_name}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "polkadot-aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.polkadot-aks.location
  resource_group_name = azurerm_resource_group.polkadot-aks.name
  dns_prefix          = "polkadot-${var.cluster_name}"
  kubernetes_version  = var.k8s_version

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.machine_type
    os_disk_size_gb = 30
    type            = "AvailabilitySet"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  enable_pod_security_policy = false
}

resource "azurerm_virtual_network" "polkadot-aks" {
  name                = "polkadot-${var.cluster_name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.polkadot-aks.location
  resource_group_name = azurerm_resource_group.polkadot-aks.name
}

resource "azurerm_subnet" "polkadot-aks" {
  name                      = "polkadot-${var.cluster_name}"
  resource_group_name       = azurerm_resource_group.polkadot-aks.name
  virtual_network_name      = azurerm_virtual_network.polkadot-aks.name
  address_prefix            = "10.0.1.0/24"
}

resource "azurerm_public_ip" "polkadot-aks" {
  name                = "polkadot-${var.cluster_name}"
  location            = azurerm_resource_group.polkadot-aks.location
  resource_group_name = azurerm_resource_group.polkadot-aks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "polkadot-aks" {
  name                = "polkadot-${var.cluster_name}"
  location            = azurerm_resource_group.polkadot-aks.location
  resource_group_name = azurerm_resource_group.polkadot-aks.name
}

resource "azurerm_network_security_rule" "outbound" {
  name                        = "outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.polkadot-aks.name
  network_security_group_name = azurerm_network_security_group.polkadot-aks.name
}

resource "azurerm_network_security_rule" "p2p" {
  name                        = "p2p"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "30100-30101"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.polkadot-aks.name
  network_security_group_name = azurerm_network_security_group.polkadot-aks.name
}

resource "azurerm_subnet_network_security_group_association" "polkadot-aks" {
  subnet_id                 = azurerm_subnet.polkadot-aks.id
  network_security_group_id = azurerm_network_security_group.polkadot-aks.id
}
