
# test sg for ec2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "EC2 Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from external"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "HTTP from external"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "80 from external"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb_sg"
  }
}


# #test instance in public subnet
# resource "aws_instance" "web" {
#   count                       = var.quantity
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id[count.index]
#   associate_public_ip_address = var.assign_public_ip
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

#   tags = {
#     Name = "test"
#   }
# }

###
#bastion
resource "aws_instance" "bastion" {
  #count                       = var.quantity
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Bastion"
  }
}

###


# # instances in private subnet
# resource "aws_instance" "web" {
#   count                       = var.quantity
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.private_subnet_ids[count.index]
#   associate_public_ip_address = var.assign_public_ip
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

#   tags = {
#     Name = "test"
#   }
# }

# jenkins master private subnet
resource "aws_instance" "jenkins_master" {
  #count                       = var.quantity
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.private_subnet_ids[0]
  associate_public_ip_address = var.assign_public_ip
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.jenkins_master_profile.name

  user_data = <<EOF
		#! /bin/bash

    ssm_running=$( ps -ef | grep ['a']mazon-ssm-agent | wc -l )
    if  $ssm_running != "0" ; then
      echo -e "amazon-ssm-agent already running"
    else
      if  -r "/tmp/ssm_agent_install" ; then : ;
      else mkdir -p /tmp/ssm_agent_install; fi
      curl https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm -o /tmp/ssm_agent_install/amazon-ssm-agent.rpm
      rpm -Uvh /tmp/ssm_agent_install/amazon-ssm-agent.rpm
      ssm_running=$( ps -ef | grep ['a']mazon-ssm-agent | wc -l )
      # Amazon Linux 2
      systemctl=$( command -v systemctl | wc -l )
      if  $systemctl != "0" ; then
        systemctl enable amazon-ssm-agent
        if  $ssm_running == "0" ; then
          systemctl start amazon-ssm-agent
        fi
      else
        # Amazon Linux
        if  $ssm_running == "0" ; then
          start amazon-ssm-agent
        fi
      fi
    fi  

		sudo yum -y install httpd
		sudo systemctl start httpd
		sudo systemctl enable httpd
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF

  tags = {
    Name = "Jenkins-Master"
  }
}

# resource "aws_ebs_volume" "ebs_vol" {
#   #availability_zone = "us-west-2a"
#   count             = var.quantity
#   availability_zone = element(var.availability_zones, count.index)
#   size              = 40

#   tags = {
#     Name = "ebs_vol"
#   }
# }

resource "aws_ebs_volume" "ebs_vol" {
  #availability_zone = "us-west-2a"
  #count             = var.quantity
  availability_zone = var.availability_zones[0]
  size              = 40

  tags = {
    Name = "ebs_vol"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.jenkins_master.id
}

# IAM

resource "aws_iam_role" "jenkins-iam-role" {
  #name = "${var.env}-${var.name}-iam-role"
  name = "jenkins-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins_master_profile" {
  name = "jenkins_master_profile"
  role = aws_iam_role.jenkins-iam-role.name
}

data "aws_iam_policy" "AmazonEC2FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins-policy-attach" {
  role       = aws_iam_role.jenkins-iam-role.name
  policy_arn = data.aws_iam_policy.AmazonEC2FullAccess.arn
}

######
# ALB resources
######

resource "aws_lb" "jenkins-lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  #subnets            = var.subnet_id
  subnets = var.public_subnet_ids

  enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}


resource "aws_lb_target_group" "jenkins-tg" {
  name     = "jenkins-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "jenkins-tga-targets" {
  #count            = var.quantity
  target_group_arn = aws_lb_target_group.jenkins-tg.arn
  #target_id        = aws_instance.web[1].id
  #target_id = element(aws_instance.web.*.id, count.index)
  target_id = aws_instance.jenkins_master.id
  port      = 80
}

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins-lb.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-tg.arn
  }
}
