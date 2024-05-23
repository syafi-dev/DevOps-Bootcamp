resource "aws_vpc" "wp-vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/24"

  tags = {
    Name = "wp-vpc"
  }
}

resource "aws_internet_gateway" "wp_internet_gateway" {
  vpc_id = aws_vpc.wp-vpc.id

  depends_on = [
    aws_vpc.wp-vpc,
  ]

  tags = {
    Name = "wp_internet_gateway"
  }
}

resource "aws_instance" "wp-server" {
  subnet_id                   = aws_subnet.wp-public-subnet-a.id
  private_ip                  = "10.0.0.5"
  key_name                    = "Syafi-SSH-Key"
  instance_type               = "t2.micro"
  availability_zone           = "ap-southeast-1a"
  associate_public_ip_address = true
  ami                         = "ami-003c463c8207b4dfa"

  tags = {
    Name        = "wp-server"
    Environment = var.tag_environment
  }

  vpc_security_group_ids = [
    aws_security_group.wp-security-group.id,
  ]
}

resource "aws_subnet" "wp-public-subnet-a" {
  vpc_id            = aws_vpc.wp-vpc.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "ap-southeast-1a"

  depends_on = [
    aws_vpc.wp-vpc,
  ]

  tags = {
    Name = "wp-public-subnet-a"
  }
}

resource "aws_route_table" "wp-route-table-a" {
  vpc_id = aws_vpc.wp-vpc.id

  depends_on = [
    aws_internet_gateway.wp_internet_gateway,
  ]

  route {
    gateway_id = aws_internet_gateway.wp_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "wp-route-table-a"
  }
}

resource "aws_route_table_association" "wp-rt_associate" {
  subnet_id      = aws_subnet.wp-public-subnet-a.id
  route_table_id = aws_route_table.wp-route-table-a.id

  depends_on = [
    aws_route_table.wp-route-table-a,
  ]
}

resource "aws_security_group" "wp-security-group" {
  vpc_id = aws_vpc.wp-vpc.id
  name   = "wp-security-group"

  egress {
    to_port     = 0
    protocol    = "-1"
    from_port   = 0
    description = "All traffic"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    to_port     = 22
    protocol    = "tcp"
    from_port   = 22
    description = "SSH"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    to_port     = 80
    protocol    = "tcp"
    from_port   = 80
    description = "HTTP"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    to_port     = 443
    protocol    = "tcp"
    from_port   = 443
    description = "HTTPS"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "wp-security-group"
  }
}

