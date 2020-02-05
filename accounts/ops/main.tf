module "app-vpc" {
  source  = "../../modules/vpc"

  company                   = "${var.company}"
  env                       = "${var.env}"
  app                       = "${var.app}"
  env_cidrs                 = "${var.env_cidrs}"
  subnet_suffixes           = "${var.subnet_suffixes}"
  subnet_bits               = "${var.subnet_bits}"
  applications              = "${var.applications}"
  services              = "${var.services}"
  azs                       = "${var.azs}"
  region                    = "${var.region}"
  vpc_cidr_block            = "${var.vpc_cidr_block}"
  domain_name               = "${var.domain_name}"
  certificate_arn               = "${var.certificate_arn}"
}

module "gatling" {
  source  = "../../modules/efs"

  env                       = "${var.env}"
  app                       = "${var.app}"
  azs                       = "${var.azs}"
  applications              = "${var.applications}"

  subnets                   = "${module.app-vpc.public_subnets}"
  outbound_security_group       = "${module.app-vpc.outbound_security_group}"
  ssh_security_group        = "${module.app-vpc.ssh_security_group}"
  nfs_security_group        = "${module.app-vpc.nfs_security_group}"
}

module "gatling-instance" {
  source  = "../../modules/ec2_asg"

  company                   = "${var.company}"
  env                       = "${var.env}"
  region                    = "${var.region}"
  app                       = "${var.app}"
  dns_zone_id               = "${var.dns_zone_id}"
  domain_name               = "${var.domain_name}"
  ec2_ami_id                = "${var.ec2_ami_id}"
  ec2_instance_type         = "${var.ec2_instance_type}"
  ec2_asg_size              = "${var.ec2_asg_size}"
  ec2_spot_prices           = "${var.ec2_spot_prices}"
  azs                       = "${var.azs}"
  applications              = "${var.applications}"
  certificate_arn              = "${var.certificate_arn}"
  services              = "${var.services}"
  vpc_list              = "${module.app-vpc.vpc_list}"

  subnets                   = "${module.app-vpc.public_subnets}"
  http_security_group       = "${module.app-vpc.http_security_group}"
  https_security_group       = "${module.app-vpc.https_security_group}"
  ssh_security_group        = "${module.app-vpc.ssh_security_group}"
  nfs_security_group        = "${module.app-vpc.nfs_security_group}"
#   subnet-pub-2a             = "${module.us-west-vpc.subnet-pub-2a}"
#   http_security_group       = "${module.us-west-vpc.http_security_group}"
#   ssh_security_group        = "${module.us-west-vpc.ssh_security_group}"
#   nfs_security_group        = "${module.us-west-vpc.nfs_security_group}"
   flask_security_group      = "${module.app-vpc.flask_security_group}"
   outbound_security_group   = "${module.app-vpc.outbound_security_group}"

  efs_file_system           = "${module.gatling.efs_file_system}"
}

module "web-s3" {
  source  = "../../modules/s3"

  company                       = "${var.company}"
  env                       = "${var.env}"
  app                       = "${var.app}"

}

