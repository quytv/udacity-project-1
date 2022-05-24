# Create the azure resource group
resource "azurerm_resource_group" "rg" {
  name     = var.prefix
  location = var.location
  tags = {
    enviroments = var.enviroments
  }
}

# Create the azure virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    enviroments = var.enviroments
  }
}

# Create the azure subnet
resource "azurerm_subnet" "gateway-subnet" {
  name                 = "${var.prefix}-GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create the azure network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "my-SGR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    enviroments = var.enviroments
  }
}

# Create azure network interface

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.gateway-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    enviroments = var.enviroments
  }
}

# Create public IP
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags = {
    enviroments = var.enviroments
  }
}

# Create load balancer

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-loadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = {
    enviroments = var.enviroments
  }
}

# Using backend pool
resource "azurerm_lb_backend_address_pool" "pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${var.prefix}-BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "npa" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

# Create virtual machine availability set
resource "azurerm_availability_set" "availabilityset" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    enviroments = var.enviroments
  }
}

data "azurerm_image" "packer" {
  name                = "packerUdacityQuytran"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create the virtual machines
resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.vm_size
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_E2bds_v5"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.nic.*.id, count.index)]
  availability_set_id             = azurerm_availability_set.availabilityset.id
  source_image_id                 = data.azurerm_image.packer.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    enviroments = var.enviroments
  }
}

#create a virtual disk for each VM created.
resource "azurerm_managed_disk" "main" {
  count                = var.vm_size
  name                 = "${var.prefix}-disk-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1
  tags = {
    enviroments = var.enviroments
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.vm_size
  managed_disk_id    = azurerm_managed_disk.main.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.vm.*.id[count.index]
  lun                = 10 * count.index
  caching            = "ReadWrite"
}


output "lb_url" {
  value       = "http://${azurerm_public_ip.pip.ip_address}/"
  description = "This is the URL for the LB."
}
