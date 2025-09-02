provider "aws" {
  region  = "us-east-1"
  # Note: Use AWS CLI profile or environment variables for credentials
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
}


#create VCP
resource "aws_vpc" "terraform_vcp" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform VPC"
    }
}


#creating Internet Gateway
resource "aws_internet_gateway" "terrafrom_Internet_gateway" {
  vpc_id = aws_vpc.terraform_vcp.id

  tags = {
    Name = "terrafrom Internet gateway"
  }
}

#createing Custom rought tables
resource "aws_route_table" "terraform_route_table" {
  vpc_id = aws_vpc.terraform_vcp.id

  route {
    cidr_block = "0.0.0.0/0"              
    gateway_id = aws_internet_gateway.terrafrom_Internet_gateway.id
  }


  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.terrafrom_Internet_gateway.id
  }


  tags = {
    Name = "terraform route table"
  }
}


#Createing Subnet
resource "aws_subnet" "terraform_subnet" {
  vpc_id     = aws_vpc.terraform_vcp.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # it better to menction the "availability_zone" because there are times when the subnet and Ec2 are created in 2 different availability_zone

  tags = {
    Name = "terraform subnet"
  }
}


#Associte subnet with the route table (This will Associte subnet with the route table)
resource "aws_route_table_association" "terraform_route_table_association" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_route_table.id
}


#security Groups for 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.terraform_vcp.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"     # -1 means any protocol 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}


#Crrated network interface in the subnet
resource "aws_network_interface" "terraform_network_interface" {
  subnet_id       = aws_subnet.terraform_subnet.id
  private_ips     = ["10.0.1.50"]     # can give the range of IP's
  security_groups = [aws_security_group.allow_web.id]
}

#Assigen the eclictic IP for thr network interface 
resource "aws_eip" "terraform_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.terraform_network_interface.id
  associate_with_private_ip = "10.0.1.50" # this is the eclictic IP for thr network interface so - "private_ips" network interface comes here
  depends_on = [aws_internet_gateway.terrafrom_Internet_gateway] # we do not menction ".id" because we are using the who internet getway not just id & when you are spicifing the depends_on yoiu need to specife as list [].
}


#create the ubintu server & install appache2 
resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0dba2cb6798deb6d8"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"  # it better to menction the "availability_zone" because there are times when the subnet and Ec2 are created in 2 different availability_zone
  key_name = "Terraform"

  network_interface {      #  Is to attach a network interface to an EC2 Instance during boot time.
                             #   The network_interface configuration block does, however, allow users to supply their -
                                  ##   - own network interface to be used as the default network interface on an EC2 Instance, attached at eth0.
     device_index = 0
     network_interface_id = aws_network_interface.terraform_network_interface.id
  }
  
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your web serevr > /var/www/html/index.html' 
                EOF
    tags = {
        Name = "Terraform ec2"
    }          
}
