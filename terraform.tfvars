resource_group_name = "rg-aks-alb-poc"
location            = "East US"

vnet_name = "vnet-aks-alb-poc"

vnet_address_space = [
  "10.0.0.0/16"
]

aks_subnet_name = "aks-subnet"

aks_subnet_prefix = [
  "10.0.0.0/22"
]

alb_subnet_name = "alb-subnet"

alb_subnet_prefix = [
  "10.0.5.0/24"
]

aks_cluster_name = "aks-alb-poc"

dns_prefix = "aksalb"

node_count = 1

vm_size = "Standard_D2s_v3"