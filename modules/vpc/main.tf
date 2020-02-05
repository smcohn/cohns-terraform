# Creates one VPC for each $services.
resource "aws_vpc" "app-vpc" {
  count = "${length(var.services)}"
  cidr_block = "${cidrsubnet("${var.env_cidrs[var.env]}",5,count.index)}"
  enable_dns_hostnames     = true
  enable_dns_support       = true

  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index]}-${var.region}-vpc"
    Environment = "${var.env}"
    Service = "${var.services[count.index]}"
  }
}


resource "aws_internet_gateway" "default" {
  count = "${length(var.services)}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index)}"
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index]}-${var.region}-vpc-igw"
    Application = "${var.services[count.index]}"
    Environment = "${var.env}"
  }
}

# Now peer the VPCs
resource "aws_vpc_peering_connection" "peer" {
  # Count and peer_vpc_id index are both offset by one to avoid trying to peer
  # one of the VPC's with itself.
  count = "${length(var.services) - 1}"
  vpc_id        = "${element(aws_vpc.app-vpc.*.id,0)}"
  peer_vpc_id   = "${element(aws_vpc.app-vpc.*.id,count.index + 1)}"
  peer_owner_id = "${element(aws_vpc.app-vpc.*.owner_id,0)}"
  auto_accept   = "true"
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index]}-${var.region}-vpc-peer"
    Application = "${var.services[count.index]}"
    Environment = "${var.env}"
  }
}

# Now set up routing between the newly peered VPCs
resource "aws_route_table" "peer-route-table" {
  count = "${length(var.services)}"
  vpc_id   = "${element(aws_vpc.app-vpc.*.id,count.index)}"
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-peer-rtb"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "public_subnet" {
  # Create one subnet in each AZ
  count      = "${length(var.services) * length(var.azs)}"
  availability_zone = "${var.region}${var.azs[count.index % length(var.azs)]}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index)}"
  cidr_block = "${cidrsubnet(element(aws_vpc.app-vpc.*.cidr_block,count.index), var.subnet_bits, count.index + length(var.services) * length(var.azs))}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}${var.azs[count.index % length(var.azs)]}-pub"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
    SubnetType = "Public"
  }
}

# Buggy--creates all of one app in one az
# Temp fix, only works for a single app.
resource "aws_subnet" "private_subnet" {
  count                     = "${length(var.services) * length(var.azs)}"
  availability_zone = "${var.region}${var.azs[count.index % length(var.azs)]}"
  vpc_id                    = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"
  cidr_block                = "${cidrsubnet(element(aws_vpc.app-vpc.*.cidr_block,count.index), var.subnet_bits, count.index)}"
  map_public_ip_on_launch   = "false"
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}${var.azs[count.index % length(var.azs)]}-prv"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
    SubnetType = "Private"
  }
}

resource "aws_route_table" "r" {
  count = "${length(var.services)}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.default.*.id,count.index)}"
  }

  tags = {
    Environment = "${var.env}"
    Company     = "${var.company}"
    Name = "${var.company}-${var.env}-${var.services[count.index]}-${var.region}-rtb"
    Terraform   = true
  }
}

resource "aws_route_table_association" "a" {
  count      = "${length(var.services) * length(var.azs)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.r.*.id, count.index % length(var.services))}"
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "${var.domain_name}"
#   validation_method = "DNS"
# 
#   tags = {
#     Environment = "dev"
#   }
# 
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_ec2_client_vpn_endpoint" "endpoint" {
#   description            = "${var.company} ${var.env} VPN"
#   server_certificate_arn = "${aws_acm_certificate.cert.arn}"
#   client_cidr_block      = "10.255.255.0/24"
# 
#  authentication_options {
#    type                       = "certificate-authentication"
#    root_certificate_chain_arn = "${aws_acm_certificate.root_cert.arn}"
#  }
# 
#   connection_log_options {
#     enabled               = false
#    cloudwatch_log_group  = "${aws_cloudwatch_log_group.lg.name}"
#    cloudwatch_log_stream = "${aws_cloudwatch_log_stream.ls.name}"
#   }
# }


# Security groups.
resource "aws_security_group" "allow_outbound" {
  count             = "${length(var.services)}"
  name              = "${element(var.services,count.index)}-allow-outbound"
  description       = "Allow outbound traffic for ${element(var.services,count.index)}"
  vpc_id            = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-outbound-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 
}

resource "aws_security_group" "allow_nfs" {
  count             = "${length(var.services)}"
  name              = "${element(var.services,count.index)}-allow-nfs"
  description       = "Allow nfs inbound traffic for ${element(var.services,count.index)}"
  vpc_id            = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-nfs-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 

}

resource "aws_security_group" "allow_ssh" {
  count          = "${length(var.services)}"
  name           = "${element(var.services,count.index)}-allow-ssh"
  description    = "Allow SSH inbound traffic for ${element(var.services,count.index)}"
  vpc_id         = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-ssh-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 
}

resource "aws_security_group" "allow_https" {
  count = "${length(var.services)}"
  name        = "${element(var.services,count.index)}-allow-https"
  description = "Allow https inbound traffic ${element(var.services,count.index)}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-https-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 
}

resource "aws_security_group" "allow_http" {
  count = "${length(var.services)}"
  name        = "${element(var.services,count.index)}-allow-http"
  description = "Allow http inbound traffic ${element(var.services,count.index)}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-http-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 
}

resource "aws_security_group" "allow_mysql" {
  count = "${length(var.services)}"
  name        = "${element(var.services,count.index)}-allow-mysql"
  description = "Allow mysql inbound traffic ${element(var.services,count.index)}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-mysql-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 
}

resource "aws_security_group" "allow_flask" {
  count = "${length(var.services)}"
  name        = "${element(var.services,count.index)}-allow-flask"
  description = "Allow flask inbound traffic for ${element(var.services,count.index)}"
  vpc_id     = "${element(aws_vpc.app-vpc.*.id,count.index % length(var.services))}"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.company}-${var.env}-${var.services[count.index % length(var.services)]}-${var.region}-flask-sg"
    Application = "${var.services[count.index % length(var.services)]}"
    Environment = "${var.env}"
  } 
}

resource "aws_ec2_client_vpn_endpoint" "dad_client_vpn" {
  description            = "dad-client-vpn"
  server_certificate_arn = "${var.certificate_arn}"
  client_cidr_block      = "192.168.0.0/20"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "${var.certificate_arn}"
#    root_certificate_chain_arn = "${aws_acm_certificate.root_cert.arn}"
  }

  connection_log_options {
    enabled               = false
#    cloudwatch_log_group  = "${aws_cloudwatch_log_group.lg.name}"
#    cloudwatch_log_stream = "${aws_cloudwatch_log_stream.ls.name}"
  }
}

# resource "aws_ec2_client_vpn_network_association" "dad_client" {
#   client_vpn_endpoint_id = "${aws_ec2_client_vpn_endpoint.dad_client_vpn.id}"
#   subnet_id              = "${aws_subnet.private_subnet[0].id}"
# }


