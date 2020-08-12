###########################################################
#Key pair creation
###########################################################

resource "aws_key_pair" "keypair" {
  key_name   = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb7ADhWTyj7GQuNEQ5mElqtXRnZD2AieHz6JLF+4BT2Uh96LVKwSi6OqrdDKWRrQOg2zmq9hDQPvNWzzKGqPwEmSbvfJAVK8ZvyaTOfcPcm7Cqfp2LZwPXd85ysLROmsVZn65kjVO8W+Yzx56zgqIfyuhqjZvGgvc5xkQBUFrN6tfdhRiF5ZyeOgasIYGoGqr7ngRnbWs1w65htCNdmS+dgDeBLtALM5YSo4E43Z/guILvZ0oQ4UCZTsnFgD7VKW1CEjqZX7MKT7VIuD60xfko2Kml8in8VmFF4EOTkXLn06XaxO3LzBFNImWhXCMdRggtzDIQQPLQLmZ97kUtjL1D root@ip-172-31-35-128.us-east-2.compute.internal"
}
###########################################################
#VPC creation
###########################################################

resource "aws_vpc" "blog" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "blog"
  }
}
###########################################################
#Subnet public - 1
###########################################################

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.blog.id
  availability_zone = "us-east-2a"
  cidr_block = "172.16.0.0/18"
  map_public_ip_on_launch = true
  tags = {
    Name = "blog-public-1"
  }
}
###########################################################
#Subnet public - 2
###########################################################

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.blog.id
  availability_zone = "us-east-2b"
  cidr_block = "172.16.64.0/18"
  map_public_ip_on_launch = true
  tags = {
    Name = "blog-public-2"
  }
}

###########################################################
#Subnet private - 2
###########################################################

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.blog.id
  availability_zone = "us-east-2c"
  cidr_block = "172.16.128.0/18"
  map_public_ip_on_launch = false
  tags = {
    Name = "blog-private-1"
  }
}
###########################################################
#Internet gateway
###########################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.blog.id

  tags = {
    Name = "blog"
  }
}
###########################################################
#Elastic ip
###########################################################

resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = "blog-nat"
  }
}


