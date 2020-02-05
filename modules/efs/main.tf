# Creates an EFS File System and mount targets in target subnet.
resource "aws_efs_file_system" "gatling" {
  creation_token = "gatling-efs"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "gatling" {
  count      = "${length(var.azs)}"
  file_system_id = "${aws_efs_file_system.gatling.id}"
  subnet_id      = "${var.subnets[count.index * length(var.applications)]}"
  security_groups    = ["${element(var.nfs_security_group.*,count.index * length(var.applications))}","${element(var.outbound_security_group.*,count.index * length(var.applications))}"]
}
