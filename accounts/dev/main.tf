# This creates one VPC per application
module "app-vpc" {
  source  = "../../modules/vpc"

  company                   = "${var.company}"
  env                       = "${var.env}"
  app                       = "${var.app}"
  services                  = "${var.services}"
  applications              = "${var.applications}"
  subnet_bits               = "${var.subnet_bits}"
  subnet_suffixes           = "${var.subnet_suffixes}"
  domain_name               = "${var.domain_name}"
  env_cidrs                 = "${var.env_cidrs}"
  azs                       = "${var.azs}"
  region                    = "${var.region}"
  vpc_cidr_block            = "${var.vpc_cidr_block}"
  certificate_arn           = "${var.certificate_arn}"
}

module "iam" {
  source = "../../modules/iam"
}

# This should be changed to create a single db, not to try to figure out by itself 
# which ones.  ie. move that logic here, and out of the moduele
module "rpm-db" {
  source  = "../../modules/rds"

  company                   = "${var.company}"
  env                       = "${var.env}"
  app                       = "${var.app}"
  applications              = "${var.applications}"
  db_applications           = "${var.db_applications}"
  db_name                   = "${var.db_name}"
  db_instance_class         = "${var.db_instance_class}"

  mysql_security_group      = "${module.app-vpc.mysql_security_group}"
  outbound_security_group   = "${module.app-vpc.outbound_security_group}"
  vpc_private_subnets_map   = "${module.app-vpc.vpc_private_subnets_map}"
  vpc_list                  = "${module.app-vpc.vpc_list}"
}

# This creates a set of instances for a particular application.
module "rpm-asg" {
  source  = "../../modules/ec2_asg"
  
  company                   = "${var.company}"
  env                       = "${var.env}"
  app                       = "${var.app}"
  region                    = "${var.region}"
  dns_zone_id               = "${var.dns_zone_id}"
  domain_name               = "${var.domain_name}"
  ec2_ami_id                = "${var.ec2_ami_id}"
  ec2_asg_size              = "${var.ec2_asg_size}"
  ec2_spot_prices           = "${var.ec2_spot_prices}"
  ec2_instance_type         = "${var.ec2_instance_type}"
  efs_file_system           = "${var.efs_file_system}"
  azs                       = "${var.azs}"
  applications              = "${var.applications}"
  services                  = "${var.services}"
  certificate_arn           = "${var.certificate_arn}"

  subnets                   = "${module.app-vpc.public_subnets}"
  http_security_group       = "${module.app-vpc.http_security_group}"
  https_security_group      = "${module.app-vpc.https_security_group}"
  ssh_security_group        = "${module.app-vpc.ssh_security_group}"
  nfs_security_group        = "${module.app-vpc.nfs_security_group}"
  flask_security_group      = "${module.app-vpc.flask_security_group}"
  outbound_security_group   = "${module.app-vpc.outbound_security_group}"
  vpc_list                  = "${module.app-vpc.vpc_list}"
  db_server_endpoint        = "${module.rpm-db.db_server_endpoint}"

  cloudfront_endpoint       = "dt2dvzih33pte.cloudfront.net"
}
