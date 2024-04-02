resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow SSH"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastion"
  }
}

data "aws_ami" "base_ami" {
  most_recent      = true
  owners           = ["amazon"]
 
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
 
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
}

resource "aws_instance" "demo-bastion" {
  ami           = data.aws_ami.base_ami.id
  instance_type = "t3.medium"
  key_name = "demo"
  subnet_id = aws_subnet.public-us-west-1a.id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "demo-bastion"
  }

}

resource "aws_eip" "demo-bastion" {
  instance = aws_instance.demo-bastion.id
}

data "aws_route53_zone" "kaplans" {
  name = "kaplans.com"
}

resource "aws_route53_record" "demo-bastion" {
  zone_id = data.aws_route53_zone.kaplans.zone_id
  name    = "demo-bastion.kaplans.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.demo-bastion.public_ip]
}
