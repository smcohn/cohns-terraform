variable "company" {
  description = "Company name for top level entity naming"
  default = "cohns"
}

variable "env" {
  description = "Environment to build"
  default = "prod"
}

variable "app" {
  description = "app to build"
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


variable "base_cidr" {
  description = "The CIDR range from which we will allocate"
  default = "10.0.0.0/8"
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
  type    = "list"
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
  default = "Z25DMIO2584N7Y"
}

variable "domain_name" {
  default = "cohns.net"
}



variable "ec2_ami_id" {
  default = "ami-0639fb5c4233c91a1"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "db_name" {
  default = "bgprod"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "efs_file_system" {
  default = ""
}

variable "ec2_instance_count" {
  default = "2"
}

variable "ec2_spot_prices" {
  default = {
    "t2.nano" = 0.0020
    "t3a.nano" = 0.0030
    "t2.micro" = 0.0060
    "t3a.micro" = 0.0060
    "t2.small" = 0.0080
    "t2.medium" = 0.0150
    "t2.large" = 0.0600
    "t3.large" = 0.0400
    "t2.xlarge" = 0.1000
  }
}

variable "ec2_asg_size" {
  default = {
    "min"     = 1
    "max"     = 1
    "desired" = 1
  }
}

variable "certificate_arn" {
  default = "arn:aws:acm:us-west-2:069717985088:certificate/fa21c11d-b01d-4580-afde-9be644794fd4"
}
