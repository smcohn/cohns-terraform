output "vpc_private_subnets_map" {
  value = [ "${aws_subnet.public_subnet[*].tags.Name}",  "${aws_subnet.public_subnet[*].id}" ]
}

# output "vpc_name_map" {
#   value = { [ "${aws_vpc.app-vpc[*].tags.Name}" ] , [ "${aws_vpc.app-vpc[*].id}" ] }
# }

output "vpc_list" {
  value = "${aws_vpc.app-vpc[*].id}"
}

output "public_subnets" {
  value = "${aws_subnet.public_subnet[*].id}"
}

output "private_subnets" {
  value = "${aws_subnet.private_subnet[*].id}"
}

output "ssh_security_group" {
  value = "${aws_security_group.allow_ssh[*].id}"
}

output "http_security_group" {
  value = "${aws_security_group.allow_http[*].id}"
}

output "https_security_group" {
  value = "${aws_security_group.allow_https[*].id}"
}

output "nfs_security_group" {
  value = "${aws_security_group.allow_nfs[*].id}"
}

output "mysql_security_group" {
  value = "${aws_security_group.allow_mysql[*].id}"
}

output "flask_security_group" {
  value = "${aws_security_group.allow_flask[*].id}"
}

output "outbound_security_group" {
  value = "${aws_security_group.allow_outbound[*].id}"
}

