variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "map_public_ip_on_launch" {
  description = "Map public IPs on subnet launch"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "teams" {
  description = "Map of teams with configurations, including subnet index and email list"
  type = map(object({
    subnet_index = number          # Unique subnet index for each team
    emails       = list(string)    # List of email addresses for each team member
  }))
}
