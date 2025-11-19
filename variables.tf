variable "aws_region" {
  type        = string
  description = "Default region of terraform configuration"
  default     = "eu-west-2"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC Cidr Block Range"
  default     = "10.80.0.0/16"
}


variable "public_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "Public subnet cidr and az configuration"
  default = {
    "public_class7_subnet_1" = {
      cidr_block = "10.80.6.0/24"
      az         = "eu-west-2a"
    }
    "public_class7_subnet_2" = {
      cidr_block = "10.80.7.0/24"
      az         = "eu-west-2b"
    }
    "public_class7_subnet_3" = {
      cidr_block = "10.80.8.0/24"
      az         = "eu-west-2c"
    }
  }
}

variable "bastion_and_rdp_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "Bastion and RDP subnet cidr and az configuration"
  default = {
    "bastion_class_7_subnet_1" = {
      cidr_block = "10.80.16.0/24"
      az         = "eu-west-2a"
    }
    "bastion_class_7_subnet_2" = {
      cidr_block = "10.80.17.0/24"
      az         = "eu-west-2b"
    }
    "bastion_class_7_subnet_3" = {
      cidr_block = "10.80.18.0/24"
      az         = "eu-west-2c"
    }
  }
}

variable "private_subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
  description = "Private subnet cidr and az configuration"
  default = {
    "private_class7_subnet_1" = {
      cidr_block = "10.80.26.0/24"
      az         = "eu-west-2a"
    }
    "private_class7_subnet_2" = {
      cidr_block = "10.80.27.0/24"
      az         = "eu-west-2b"
    }
    "private_class7_subnet_3" = {
      cidr_block = "10.80.28.0/24"
      az         = "eu-west-2c"
    }
  }
}


variable "instance_type" {
  type        = string
  description = "EC2 Instance Type for our LT01"
  default     = "t3.micro"
}
