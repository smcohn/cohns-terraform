data "aws_subnet_ids" "private" {
  # This puts all the privs in one list.  Fix me
  count  = "${length(var.vpc_list)}"
  vpc_id = "${element(var.vpc_list,count.index)}"

  tags = {
    SubnetType = "Private"
  }
}

resource "aws_db_subnet_group" "rpm" {
  count          = "${length(var.applications)}"

  name           = "${var.company}-${var.env}-${var.app}-db-subnets"
  subnet_ids     = "${data.aws_subnet_ids.private[count.index].ids}"
  description    = "DB Subnet Group"
  tags = {
    Company        = "${var.company}"
    Name           = "${var.company}-${var.env}-${var.app}-db-subnets"
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "rds-enhanced-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_db_instance" "rpm" {
  # Replace with "db_applications", a subset of applications.
  count                     = "${length(var.applications)}"

  apply_immediately         = "true"
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "5.5"
  ca_cert_identifier        = "rds-ca-2019"
  instance_class            = var.db_instance_class
  name                      = var.db_name
  username                  = "root"
  password                  = "r0ck&R011"
  parameter_group_name      = "default.mysql5.5"
  monitoring_interval       = "1"
  monitoring_role_arn       = aws_iam_role.rds_enhanced_monitoring.arn
  vpc_security_group_ids    = ["${var.mysql_security_group[count.index]}", "${var.outbound_security_group[count.index]}"]
  identifier                = "${var.company}-${var.env}-${var.app}-db"
#  snapshot_identifier      = "${var.company}-${var.env}-${var.app}-db-snap"
  snapshot_identifier       = "arn:aws:rds:us-west-2:069717985088:snapshot:cohns-prod-rpm-db-snap"
  db_subnet_group_name      = "${var.company}-${var.env}-${var.app}-db-subnets"
  skip_final_snapshot       = "true"
}
