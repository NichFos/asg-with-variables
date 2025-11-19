resource "aws_security_group" "tg01-sg01" {
  name        = "tg01-sg01"
  description = "Allow Port 80 for TG01"
  vpc_id      = aws_vpc.class_7_vpc.id

  tags = {
    Name    = "class_7_sg"
    Service = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tg01_ipv4" {
  security_group_id = aws_security_group.tg01-sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_tg01_ipv4" {
  security_group_id = aws_security_group.tg01-sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_security_group" "alb-01-sg01" {
  name        = "alb-01-sg01"
  description = "Web Load Balancer"
  vpc_id      = aws_vpc.class_7_vpc.id

  tags = {
    Name = "lee-loves-lizzo-load-balancing"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_alb_01_ipv4" {
  security_group_id = aws_security_group.alb-01-sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_alb__ipv4" {
  security_group_id = aws_security_group.alb-01-sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}