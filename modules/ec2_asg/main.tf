# EC2 Autoscaling Group Module.
# Creates a launch template, target group, load balancer, and DNS entry
# TODO: Remove all the "count" stuff.
#       Move choice of LT type to a variable SPOT/DEMAND
#       Make account number for S3 bucket name a derived variable.
#       

# Here is where startup script for the instances goes
data "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"
  vars = {
    db_server_endpoint = "${var.db_server_endpoint}"
    cloudfront_endpoint = "${var.cloudfront_endpoint}"
  }
}

data "aws_subnet_ids" "public" {
  count  = "${length(var.vpc_list)}"
  vpc_id = "${element(var.vpc_list,count.index)}"
  tags = {
    SubnetType = "Public"
  }
}

resource "aws_launch_template" "demand-lt" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-demand-lt"
  image_id                  = var.ec2_ami_id
  key_name                  = "${var.company}-${var.env}-${var.app}-key"
  instance_type             = "${var.ec2_instance_type}"
  vpc_security_group_ids    = ["${element(var.ssh_security_group.*,count.index)}","${element(var.http_security_group.*,count.index)}","${element(var.https_security_group.*,count.index)}","${element(var.outbound_security_group.*,count.index)}"]
  user_data                 = "${base64encode(data.template_file.user_data.rendered)}"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Company = "${var.company}"
      Environment = "${var.env}"
      Application = "${var.app}"
      Name = "${var.company}-${var.env}-${var.region}-${var.app}-instance"
    }
  }
}

resource "aws_launch_template" "spot-lt" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-spot-lt"
  image_id                  = var.ec2_ami_id
  key_name                  = "${var.company}-${var.env}-${var.app}-key"
  instance_type             = "${var.ec2_instance_type}"
  vpc_security_group_ids    = ["${element(var.ssh_security_group.*,count.index)}","${element(var.http_security_group.*,count.index)}","${element(var.https_security_group.*,count.index)}","${element(var.outbound_security_group.*,count.index)}"]
  user_data                 = "${base64encode(data.template_file.user_data.rendered)}"
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "${var.ec2_spot_prices[var.ec2_instance_type]}"
      spot_instance_type = "one-time"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Company = "${var.company}"
      Environment = "${var.env}"
      Application = "${var.app}"
      Name = "${var.company}-${var.env}-${var.region}-${var.app}-instance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-asg"
  availability_zones        = ["us-west-2a", "us-west-2b"]
  vpc_zone_identifier       = "${data.aws_subnet_ids.public[count.index].ids}"
  desired_capacity          = "${var.ec2_asg_size["desired"]}"
  max_size                  = "${var.ec2_asg_size["max"]}"
  min_size                  = "${var.ec2_asg_size["min"]}"
  health_check_type         = "ELB"

  launch_template {
    id      = "${aws_launch_template.spot-lt[count.index].id}"
    version = "$Latest"
  }
}

resource "aws_lb" "alb" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-alb"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = ["${element(var.ssh_security_group.*,count.index)}","${element(var.http_security_group.*,count.index)}","${element(var.https_security_group.*,count.index)}","${element(var.outbound_security_group.*,count.index)}"]
  subnets                   = "${data.aws_subnet_ids.public[count.index].ids}"

  enable_deletion_protection = false

   access_logs {
#     bucket  = "${aws_s3_bucket.lb_logs.bucket}"
     bucket = "451089431772-logs"
     prefix  = "${var.app}"
     enabled = true
   }

  tags = {
    Company = "${var.company}"
    Environment = "${var.env}"
    Application = "${var.app}"
    Name = "${var.company}-${var.env}-${var.region}-${var.app}-asg"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  count                     = "${length(var.services)}"
  name                      = "${var.company}-${var.env}-${var.app}-${var.region}-tg"
  port                      = 80
  protocol                  = "HTTP"
  vpc_id                    = "${element(var.vpc_list,count.index)}"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = "3600"
    enabled         = "true"
  }
  health_check {
    enabled         = "true"
    interval        = "10"
    timeout         = "2"
    path            = "/php/login.php"
    matcher         = "200-299"
  }
}

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

resource "aws_lb_listener" "https" {
  count                     = "${length(var.services)}"
  load_balancer_arn = "${aws_lb.alb[count.index].arn}"
  certificate_arn   = "${var.certificate_arn}"
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_target_group[count.index].arn}"
  }
}

resource "aws_route53_record" "record" {
  count                     = "${length(var.services)}"
  zone_id                   = var.dns_zone_id
  name		            = "${var.app}.${var.env}.${var.domain_name}"
  type                      = "CNAME"
  ttl                       = "300"
  records                   = ["${aws_lb.alb[count.index].dns_name}"]
}

