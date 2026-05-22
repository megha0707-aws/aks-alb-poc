variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_name" {
  type = string
}

variable "aks_subnet_prefix" {
  type = list(string)
}

variable "alb_subnet_name" {
  type = string
}

variable "alb_subnet_prefix" {
  type = list(string)
}

variable "aks_cluster_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}
variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}