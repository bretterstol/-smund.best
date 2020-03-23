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