data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


resource "aws_launch_template" "asg-LT01" {
  name_prefix   = "asg-LT01"
  image_id      = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.tg01-sg01.id]

  user_data = filebase64("./startup.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "asg-instance"
      Service = "Auto Scaling"
      Owner   = "Nick"
      Planet  = "ZDR"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}