#Create VPC
resource "aws_vpc" "wp-vpc" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

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