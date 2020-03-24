
provider "aws" {
  profile = "default"
  region = var.region
}

/*
  VPC AND SUBNETS
*/
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
      Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_public_cidr
  tags = {
      Name = "Public main"
  }
}
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_private_cidr
  tags = {
      Name = "Private main"
  }
}

/*
  ROUTE TABLES
*/
resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_all
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main Public route"
  }
}

resource "aws_route_table" "priv_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_all
    gateway_id = aws_nat_gateway.ng.id
  }

  tags = {
    Name = "main Private route"
  }
}

resource "aws_route_table_association" "public_route_ass" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table_association" "private_route_ass" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.priv_route.id
}

/*
  EIP IGW NATGW
*/
resource "aws_eip" "nat" {
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "Nat GW"
  }
}

/*
    SECURITY GROUPS
*/
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  egress = var.default_egress

  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  egress = var.default_egress

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "bastion_sec" {
  name        = "bastion_sec"
  description = "Allow ssh from my ip"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from My ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress = var.default_egress
  tags = {
    Name = "bastion_sec"
  }
}

resource "aws_security_group" "worker_sec" {
  name        = "worker_sec"
  description = "Allow ssh from bastion and to port 4000 from webserver"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [
      aws_security_group.bastion_sec.id
    ]
  }
  ingress {
    description = "Port 4000 from webserver"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    security_groups = [
      aws_security_group.allow_http.id
    ]
  }
  egress = var.default_egress

  tags = {
    Name = "worker_sec"
  }
}

resource "aws_security_group" "redis_sec" {
  name        = "redis_sec"
  description = "Allow ssh from bastion and to port 6379 from worker"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [
      aws_security_group.bastion_sec.id
    ]
  }
  ingress {
    description = "Port 6379 from worker"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [
      aws_security_group.worker_sec.id
    ]
  }
  egress = var.default_egress
  tags = {
    Name = "redis_sec"
  }
}
/*
  EC2 INSTANCES
*/
resource "aws_instance" "webserver" {
  ami = var.ec2_ami
  subnet_id = aws_subnet.public.id
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.allow_http.id, 
    aws_security_group.allow_ssh.id
  ]
  key_name = var.ssh_key
  associate_public_ip_address = true
  tags = {
    Name = "Webserver"
  }
  user_data = file("install_nginx.sh")
}

resource "aws_instance" "bastion" {
  ami = var.ec2_ami
  subnet_id = aws_subnet.public.id
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.bastion_sec.id, 
  ]
  key_name = var.ssh_key
  associate_public_ip_address = true
  tags = {
    Name = "Bastion"
  }
}
resource "aws_instance" "worker" {
  ami = var.ec2_ami
  subnet_id = aws_subnet.private.id
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.worker_sec.id, 
  ]
  key_name = var.ssh_key
  tags = {
    Name = "worker"
  }
}
resource "aws_instance" "redis_server" {
  ami = var.ec2_ami
  subnet_id = aws_subnet.private.id
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.redis_sec.id, 
  ]
  key_name = var.ssh_key
  tags = {
    Name = "redis_server"
  }
}