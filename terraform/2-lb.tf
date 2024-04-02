resource "aws_lb" "demo-lb" {
  name               = "demo-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [ aws_subnet.public-us-west-1a.id, aws_subnet.public-us-west-1c.id ]
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "demo-tg" {
  name     = "demo-tg"
  port     = 8192
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo.id
}

data "aws_acm_certificate" "demo-certificate" {
  domain      = "kaplans.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "demo_fe" {
  load_balancer_arn = aws_lb.demo-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.demo-certificate.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-tg.arn
  }
}

resource "aws_launch_template" "demo_launch_templ" {
  name_prefix   = "demo_launch_templ"
  image_id      = "ami-086e2343a4a6631d8" # in us-west-1
  instance_type = "t2.micro"
  key_name      = "demo"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.demo-target-sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "demo-instance" # Name for the EC2 instances
    }
  }
}

resource "aws_autoscaling_group" "demo_asg" {
  # no of instances
  desired_capacity = 2
  max_size         = 10
  min_size         = 1

  # Connect to the target group
  target_group_arns = [aws_lb_target_group.demo-tg.arn]

  vpc_zone_identifier = [ 
    aws_subnet.private-us-west-1a.id,
    aws_subnet.private-us-west-1a.id,
  ]

  launch_template {
    id      = aws_launch_template.demo_launch_templ.id
  }
}

resource "aws_security_group" "demo-lb-sg" {
  name        = "Demo LB Security Group"
  vpc_id      = aws_vpc.demo.id
  
  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "demo-target-sg" {
  name        = "Demo target Security Group"
  vpc_id      = aws_vpc.demo.id
  
  # Inbound Rules
  # HTTP access from load balancer
  ingress {
    from_port   = 8192
    to_port     = 8192
    protocol    = "tcp"
    cidr_blocks = ["16.0.0.0/16"]
    # security_groups is more restrictive (i.e. better), but doesn't seem to work
    # security_groups = [aws_security_group.demo-lb-sg.id]
  }
  # SSH from inside the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
