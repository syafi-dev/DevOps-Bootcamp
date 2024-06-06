#Create VPC
resource "aws_vpc" "wp-vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/24"
  instance_tenancy     = "default"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#Create Public Subnet
resource "aws_subnet" "wp-public-subnet-1" {
  vpc_id            = aws_vpc.wp-vpc.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "${var.project_name}-public-subnet-1"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "wp-internet-gateway" {
  vpc_id = aws_vpc.wp-vpc.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

#Create Route Table
resource "aws_route_table" "wp-route-table-1" {
  vpc_id = aws_vpc.wp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp-internet-gateway.id
  }

  tags = {
    Name = "${var.project_name}-route-table-1"
  }
}

#Associate Route Table
resource "aws_route_table_association" "wp-route-table-1-associate" {
  subnet_id      = aws_subnet.wp-public-subnet-1.id
  route_table_id = aws_route_table.wp-route-table-1.id
}

#Create Security Group
resource "aws_security_group" "wp-security-group" {
  name   = "wp-security-group"
  vpc_id = aws_vpc.wp-vpc.id

  tags = {
    Name = "${var.project_name}-security-group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create EC2 Server
resource "aws_instance" "wp-server" {
  ami           = "ami-003c463c8207b4dfa"
  instance_type = "t2.micro"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  vpc_security_group_ids      = [aws_security_group.wp-security-group.id]
  subnet_id                   = aws_subnet.wp-public-subnet-1.id
  private_ip                  = "10.0.0.5"
  associate_public_ip_address = true
  key_name                    = "Syafi-SSH-Key"

  tags = {
    Name = "${var.project_name}-server"
  }
}