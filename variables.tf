#not providing any default value , forcing user to provide value
variable "cidr_block" {
}
#this is optional , because its is good to provide tags
variable "common_tags" {
    default = {}
}
#not providing any default value , forcing user to provide value.This is required
variable "project_name" {  
}
variable "env" {
}

#this is optional , because we gave default value
variable "vpc_tags" {
    default = {}
}

#this is optional , because we gave default value
variable "enable_dns_hostnames" {
  default = true
}
#this is optional , because we gave default value
variable "enable_dns_support" {
   default = {}
}

variable "igw_tags" {
  default = {}
}

#Here below condition is we want only two subnets to be created other wise display error
variable "public_subnet_cidr" {
  type        = list

  validation {
    condition     = length(var.public_subnet_cidr) == 2
    error_message = "Please provide 2 public subnet cidr"
  } 
}

variable "private_subnet_cidr" {
    type = list 

    validation {
      condition = length(var.private_subnet_cidr) == 2
      error_message = "Please provide 2 private subnet cidr"
    }
}

variable "database_subnet_cidr" {
    type = list 

    validation {
      condition = length(var.database_subnet_cidr) == 2
      error_message = "Please provide 2 database subnet cidr"
    }
}

variable "nat_gateway_tags" {
 default = {} 
}

variable "private_route_table_tags" {
  default = {}
}

variable "public_route_table_tags" {
  default = {}
}

variable "database_route_table_tags" {
  default = {} 
}

variable "db_subnet_group_tags" {
   default = {}  
}

variable "is_peering_required" {
  default = false
}
variable "requestor_vpc_id" {
 
}

variable "default_route_table_id" {
  
}

variable "default_vpc_cidr" {
  
}