#-------- vpc/main.tf --------
#=============================
provider "aws" {
    region = var.region
}

#Get all available AZ's in VPC for this region
#===============================================
data "aws_availability_zone" "bf_azs" {
    state = "available"
}

#Create VPC in ca-central-1
#===========================
resource "aws_vpc" "bf_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "BizForo-VPC"
  }
}

#Create IGW in ca-central-1
#===========================
resource "aws_internet_gateway" "bf_igw" {
  vpc_id = aws_vpc.bf_vpc.id
  tags = {
    Name = "BizForo-Gateway"
  }
}

#Create public route table in ca-central-1
#===========================================
resource "aws_route_table" "bf_public_route" {
    vpc_id = aws_vpc.bf_vpc.id
    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.bf_igw.id
    }
    tags = {
        Name = "BizForo-Public-RouteTable"
    }
}

#Create subnet#1 in ca-central-1
#================================
resource "aws_subnet" "bf_public_subnet" {
  availability_zone = element(data.aws_availability_zone.bf_azs.names, 0)
  vpc_id            = aws_vpc.bf_vpc.id
  cidr_block        =  "10.0.1.0/24"
  tags = {
    Name = "BizForo-Subnet"
  }
}
resource "aws_route_table_association" "bf_public_assoc" {
  subnet_id         = aws_subnet.bf_public_subnet.id
  route_table_id    = aws_subnet.bf_public_route.id
}

#Create SG for allowing TCP/80 & TCP/22 & TCP/9000
#====================================================
resource "aws_security_group" "bf_public_sg" {
  name          = "bf_public_sg"
  description   = "Used for accessing to the public instances"
  vpc_id        = aws_vpc.bf_vpc.id

  #SSH
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  #HTTP 80
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP 9000
  ingress {
    description = "allow traffic from TCP/9000"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BizForo-SecurityGroup"
  }
}