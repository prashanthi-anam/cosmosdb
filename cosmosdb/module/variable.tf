variable "resource_group" {
    description = "resourcegrp name"
    type = string
  
}
variable "location" {
    description = "location of resource"
    type = string
  
}

variable "vnet_address_space" {
  description = "adress space for vnet"
  type = string
  
}
variable "subnet_address_prefix" {
  description = "adress space for subnet"
  type = string
}