variable "prefix" {
  default = "udacity-quytran"
  type    = string
}

variable "location" {
  default     = "East US 2"
  description = "Location of the resource group."
  type        = string
}

variable "enviroments" {
  default = "Test"
  type    = string
}

variable "vm_size" {
  type    = number
  default = 1
  validation {
    condition     = var.vm_size > 0
    error_message = "VM must be greater than 0"
  }
}

variable "username" {
  type    = string
  default = "adminuser"
}

variable "password" {
  type    = string
  default = "RW49eLura6XLUDda"
}
