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

###########################################################
#Natgate way
###########################################################

resource "aws_nat_gateway" "blog" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public2.id
  tags = {
    Name = "blog-nat"
  }
}
###########################################################
#Route table public
###########################################################

resource "aws_route_table" "terraform-public" {
  vpc_id = aws_vpc.blog.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform_public"
  }
}
###########################################################
#Route table private
###########################################################

resource "aws_route_table" "terraform-private" {
  vpc_id = aws_vpc.blog.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.blog.id
  }

  tags = {
    Name = "terraform_private"
  }
}
###########################################################
# route association blog-public1
###########################################################

resource "aws_route_table_association" "blog-public-1" {
  subnet_id         = aws_subnet.public1.id
  route_table_id = aws_route_table.terraform-public.id
}

###########################################################
# route association blog-public2
###########################################################

resource "aws_route_table_association" "blog-public-2" {
  subnet_id         = aws_subnet.public2.id
  route_table_id = aws_route_table.terraform-public.id
}

###########################################################
# route association blog-private1
###########################################################

resource "aws_route_table_association" "blog-private-1" {
  subnet_id         = aws_subnet.private1.id
  route_table_id = aws_route_table.terraform-public.id
}
###########################################################
#Security group bastion
###########################################################

resource "aws_security_group" "bastion" {
  name        = "blog-bastion"
  description = "allow 22"
  vpc_id      = aws_vpc.blog.id

  ingress {
  
    from_port   = 22
    to_port     = 22
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
    Name = "blog-bastion"
  }
}

###########################################################
#Security Group webserver
###########################################################
resource "aws_security_group" "webserver" {
  name        = "blog-webserver"
  description = "Allow 80 and 22 from bastion"
  vpc_id      = aws_vpc.blog.id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.bastion.id]
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


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blog-webserver"
  }
}


###########################################################
# Security Group database
###########################################################

resource "aws_security_group" "database" {
  name        = "blog-database"
  description = "allow 3306 from webserver and 22 from bastion"
  vpc_id      = aws_vpc.blog.id

  ingress {
    
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.webserver.id ]
   
   }
    
  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.webserver.id ]
  }

  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blog-database"
  }
}
