variable "company" {
  description = "Company name for top level entity naming"
  default = "cohns"
}

variable "env" {
  description = "Environment to build"
  default = "dev"
}

variable "app" {
  description = "App to build"
  default = "rpm"
}

variable "services" {
  description = "Services"
  default = ["rpm"]
}

variable "applications" {
  description = "Applications"
  default = ["rpm"]
}

variable "db_applications" {
  description = "Applications that need a DB"
  default = ["rpm"]
}

variable "vpc_cidr_block" {
  description = "The CIDR range from which we will allocate"
  default = "10.0.0.0/16"
}

variable "env_cidrs" {
  type = "map"
  default = {
    ops = "10.0.0.0/11"
    dev = "10.32.0.0/11"
    stage = "10.64.0.0/11"
    prod = "10.96.0.0/11"
  }
}

variable "region" {
  default = "us-west-2"
}

variable "azs" {
  type    = list
  default = ["a", "b"]
}

variable "subnet_suffixes" {
  description = "Create subnets with these names"
  default     = ["pub", "prv"]
}

variable "subnet_bits" {
  description = "Number of bits to add on to vpc cidr"
  default     = "5"
}

variable "vpc_subnet_bits" {
  description = "Number of bits to add on to env cidr for each vpc"
  default     = "6"
}

variable "dns_zone_id" {
  default = "Z29QACZJCP714N"
}

variable "domain_name" {
  default = "cohns.net"
}

variable "ec2_ami_id" {
  default = "ami-05217aa832e6c14f9"
}

# variable "ec2_ami_id" {
#   default = "ami-0fcc99e6fde80c314"
# }

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_spot_prices" {
  default = {
    "t2.nano" = 0.0018
    "t3a.nano" = 0.0018
    "t2.micro" = 0.0045
    "t3a.micro" = 0.0045
    "t2.small" = 0.0060
    "t2.medium" = 0.0150
    "t2.large" = 0.0500
    "t3.large" = 0.0300
    "t2.xlarge" = 0.0990
  }
}  

variable "ec2_asg_size" {
  default = {
    "min" = 1
    "max" = 1
    "desired" = 1
  }
}

variable "db_name" {
  default = "bgprod"
}

variable "db_instance_class" {
  default = "db.t2.micro"
}

variable "efs_file_system" {
  default = ""
}

variable "ec2_instance_count" {
  default = "2"
}

variable "certificate_arn" {
  default = "arn:aws:acm:us-west-2:451089431772:certificate/8ed6d3ac-6bc0-4d2b-8ffc-eab10e8cce34"
}

variable "db_snapshot_arn" {
  default = "arn:aws:rds:us-west-2:069717985088:snapshot:cohns-prod-rpm-db-snap"
}

