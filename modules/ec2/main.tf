# EC2 Module.
data "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"
  vars = {
    efs_filesystem = "${var.efs_file_system}"
  }
}

data "aws_subnet_ids" "public" {
  # This puts all the privs in one list.  Fix me
  count  = "${length(var.vpc_list)}"
  vpc_id = "${element(var.vpc_list,count.index)}"

  tags = {
    SubnetType = "Public"
  }
}

# Build instance_count ec2 instances in $VPC
# Build them in public subnets, spread across azs
# This should probably end up in a module called ec2_instance that gets called from elsewhere.  
# The rest of this module should be expanded to include ASG's and LB's

# resource "aws_instance" "instance" {
#   # VPC "${lookup( var.vpc_name_map, "cohns-dev-rpm-us-west-vpc", "foo")}"
# 
#   count                     = "${var.ec2_instance_count}"
#   ami                       = var.ec2_ami_id
#   instance_type             = "${var.ec2_instance_type}"
#   # This should use aws_subnets to find the right ones.
#   subnet_id                 = "${var.subnets[count.index * length(var.services)]}"
##    key_name                  = "${var.company}-${var.env}-${var.app}-key"
#  user_data                 = "${data.template_file.user_data.rendered}"
#   vpc_security_group_ids    = ["${element(var.ssh_security_group.*,count.index * length(var.services))}","${element(var.http_security_group.*,count.index * length(var.services))}","${element(var.outbound_security_group.*,count.index * length(var.services))}"]
#   tags = {
#     Name = "${var.company}-${var.env}-${var.app}-${var.region}${var.azs[count.index % length(var.azs)]}-instance"
#   Application = "${var.services[count.index]}"
#     Environment = "${var.env}"
#   }
# }

resource "aws_launch_template" "lt" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-lt"
  image_id                  = var.ec2_ami_id
  key_name                  = "${var.company}-${var.env}-${var.app}-key"
  instance_type             = "${var.ec2_instance_type}"
  vpc_security_group_ids    = ["${element(var.ssh_security_group.*,count.index)}","${element(var.http_security_group.*,count.index)}","${element(var.outbound_security_group.*,count.index)}"]
  user_data                 = "${base64encode(data.template_file.user_data.rendered)}"
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.company}-${var.env}-${var.region}-${var.app}-instance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-asg"
  availability_zones = ["us-west-2a"]
  vpc_zone_identifier = "${data.aws_subnet_ids.public[count.index].ids}"
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  health_check_type  = "ELB"


  launch_template {
    id      = "${aws_launch_template.lt[count.index].id}"
    version = "$Latest"
  }
}

resource "aws_lb" "alb" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-alb"
  internal           = false
  load_balancer_type = "application"
#  security_groups    = ["${aws_security_group.lb_sg.id}"]
  security_groups    = ["${element(var.ssh_security_group.*,count.index)}","${element(var.http_security_group.*,count.index)}","${element(var.outbound_security_group.*,count.index)}"]
  subnets = "${data.aws_subnet_ids.public[count.index].ids}"

  enable_deletion_protection = false

#   access_logs {
#     bucket  = "${aws_s3_bucket.lb_logs.bucket}"
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = "${element(var.vpc_list,count.index)}"
}

#Autoscaling Attachment
resource "aws_autoscaling_attachment" "svc_asg_external" {
  count                     = "${length(var.services)}"
  alb_target_group_arn   = "${aws_lb_target_group.alb_target_group[count.index].arn}"
  autoscaling_group_name = "${aws_autoscaling_group.asg[count.index].id}"
}

resource "aws_lb_listener" "http" {
  count                     = "${length(var.services)}"
  load_balancer_arn = "${aws_lb.alb[count.index].arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_target_group[count.index].arn}"
  }
}

resource "aws_route53_record" "record" {
  count                     = "${length(var.services)}"
  zone_id                   = var.dns_zone_id
#  name                      = "${var.app}${trimprefix(aws_instance.instance[count.index].id,"i")}.${var.env}.${var.domain_name}"
  name		             = "${var.app}.${var.env}.${var.domain_name}"
  type                      = "CNAME"
  ttl                       = "300"
#  records                   = ["${aws_instance.instance[count.index].public_ip}"]
  records                   = ["${aws_lb.alb[count.index].dns_name}"]
}

