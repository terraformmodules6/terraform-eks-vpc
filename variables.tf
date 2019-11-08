variable "platform_name" {
  type = "string"
}

variable vpc_id {
  description = "VPC id if you would like to use existing VPC"
  default     = ""
}

variable private_subnet_ids {
  description = "Private subnet IDs if you would like to use existing. Routing table won't be created."
  type        = "list"
  default     = []
}

variable public_subnet_ids {
  description = "Public subnet IDs if you would like to use existing. Routing table won't be created."
  type        = "list"
  default     = []
}

variable "platform_cidr" {
  type = "string"
}

variable "private_cidrs" {
  type = "list"
}

variable "public_cidrs" {
  type = "list"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources."
}
