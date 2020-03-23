variable "region" {
    default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_public_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet_private_cidr" {
  default = "10.0.2.0/24"
}

variable "ec2_ami" {
  default = "ami-0fc61db8544a617ed"
}

variable "my_ip" {
  default = "81.191.204.226/32"
}

variable "cidr_all" {
  default = "0.0.0.0/0"
}

variable "ssh_key" {
  default = "MYUSE1KP"
}

variable "default_egress" {
  type = list(object({
    description = string
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids = list(string)
    security_groups = list(string)
    self = bool
  }))

  default = [{
    description = "Allow all to all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]
}