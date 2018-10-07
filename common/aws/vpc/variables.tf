#### Variables ####

# Required

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = "string"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = "string"
}

variable "azs" {
  description = "A list of availability zones to create public and private subnets"
  type        = "list"
}

variable "public_subnets" {
  description = "A list of public subnet CIDRs inside the VPC"
  type        = "list"
}

variable "private_subnets" {
  description = "A list of private subnet CIDRs inside the VPC"
  type        = "list"
}


# Optional

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames within the VPC"
  type        = "string"
  default     = "false"
}

variable "enable_dns_support" {
  description = "Enable the Amazon DNS service within the VPC"
  type        = "string"
  default     = "true"
}

variable "enable_nat_gateway" {
  description = "Provision NAT gateways for each private subnet"
  type        = "string"
  default     = "false"
}

variable "single_nat_gateway" {
  description = "Provision a single NAT gateway for all private networks"
  type        = "string"
  default     = "false"
}

variable "one_nat_gateway_per_az" {
  description = "Provision one NAT gateway per availability zone"
  type        = "string"
  default     = "false"
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP on launch"
  type        = "string"
  default     = "true"
}

variable "local_domain_name" {
  description = "Name of the local domain"
  type        = "string"
  default     = "local"
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = "list"
  default     = ["AmazonProvidedDNS"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {}
}
