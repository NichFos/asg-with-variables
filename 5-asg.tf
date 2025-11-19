resource "aws_lb_target_group" "tg01-from-terraform" {
  name        = "tg01-from-terraform"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.class_7_vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name    = "tg01-from-terraform"
    Service = "TG for ASG"
    Owner   = "Nick"
  }
}

resource "aws_lb" "alb-from-terraform" {
  name                       = "alb-from-terraform"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-01-sg01.id]
  subnets                    = [for i in aws_subnet.public_class_7_subnet : i.id]
  enable_deletion_protection = false
  #Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "alb-from-terraform"
    Service = "Load Balancing"
    Owner   = "Nick"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb-from-terraform.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg01-from-terraform.arn
  }
}



resource "aws_autoscaling_group" "asg01-from-terraform" {
  name_prefix               = "asg01-from-terraform"
  min_size                  = 3
  max_size                  = 9
  desired_capacity          = 6
  vpc_zone_identifier       = [for i in aws_subnet.private_class_7_subnet : i.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.tg01-from-terraform.arn]

  launch_template {
    id      = aws_launch_template.asg-LT01.id
    version = "$Latest"
  }

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  # Instance protection for launching
  initial_lifecycle_hook {
    name                  = "instance-protection-launch"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 60
    notification_metadata = "{\"key\":\"value\"}"
  }

  # Instance protection for terminating
  initial_lifecycle_hook {
    name                 = "scale-in-protection"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
  }

  tag {
    key                 = "Name"
    value               = "asg01-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Purpose"
    value               = "Demo"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "asg01-scaling-policy" {
  name                   = "asg01-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.asg01-from-terraform.name

  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# Enabling instance scale-in protection
resource "aws_autoscaling_attachment" "asg01-from-terraform-attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg01-from-terraform.name
  lb_target_group_arn    = aws_lb_target_group.tg01-from-terraform.arn
}
