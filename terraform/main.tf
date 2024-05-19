provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "project"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.vpc_id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public"
  }
}


resource "aws_subnet" "main2" {
  vpc_id     = aws_vpc.main.vpc_id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gate"
  }
}


resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "example2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}


resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "gw NAT"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  security_group = aws_security_group.allow_tls.id
  key_pair = aws_key_pair.deployer.id
  

  tags = {
    Name = "HelloWorld"
  }
} 