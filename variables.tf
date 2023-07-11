variable "region" {
  type        = string
  default     = "eu-central-1"
}

variable "cidr_vpc" {
  description = "CIDR for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "cidr_private_subnet_A" {
  description = "CIDR for Privat Subnet A"
  type        = string
  default     = "192.168.10.0/24"
}

variable "cidr_private_subnet_B" {
  description = "CIDR for Privat Subnet B"
  type        = string
  default     = "192.168.20.0/24"
}

variable "cidr_public_subnet_A" {
  description = "CIDR for Public Subnet A"
  type        = string
  default     = "192.168.11.0/24"
}

variable "cidr_public_subnet_B" {
  description = "CIDR for Public Subnet B"
  type        = string
  default     = "192.168.21.0/24"
}

variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
    Project = "TEST"
    Owner       = "Stas I"
    Environment = "Development"
  }
}