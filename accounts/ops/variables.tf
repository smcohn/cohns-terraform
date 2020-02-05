variable "company" {
  description = "Company name for top level entity naming"
  default = "cohns"
}

variable "env" {
  description = "Environment to build"
  default = "ops"
}

variable "app" {
  default = "gatling"
}

variable "vpc_cidr_block" {
  description = "The CIDR range from which we will allocate"
  default = "10.0.0.0/16"
}

variable "services" {
  default = [ "gatling" ]
}

variable "applications" {
  default = [ "gatling" ]
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
  default = ["a", "b"]
}

variable "subnet_suffixes" {
  description = "Create subnets with these names"
  default     = ["pub", "prv"]
}

variable "dns_zone_id" {
    default = "Z9P1JIDNNGC91"
}

variable "domain_name" {
    default = "cohns.net"
}

variable "ec2_ami_id" {
    default = "ami-0a85857bfc5345c38"
}

variable "ec2_instance_type" {
    default = "t3a.nano"
}

variable "ec2_instance_count" {
    default = "2"
}

variable "subnet_bits" {
    default = "4"
}

variable "certificate_arn" {
    default = "arn:aws:acm:us-west-2:534539339440:certificate/3423c19c-5e0e-4c07-8ece-51c2fda39d25"
}


variable "ec2_spot_prices" {
  default = {
    "t2.nano" = 0.0020
    "t3a.nano" = 0.0020
    "t2.micro" = 0.0050
    "t3a.micro" = 0.0050
    "t2.small" = 0.0070
    "t2.medium" = 0.0150
    "t2.large" = 0.0600
    "t3.large" = 0.0400
    "t2.xlarge" = 0.1000
  }
}

variable "ec2_asg_size" {
  default = {
    "min" = 1
    "max" = 1
    "desired" = 1
  }
}


