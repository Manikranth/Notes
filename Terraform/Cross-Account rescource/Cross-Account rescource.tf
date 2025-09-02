provider "aws" {
  region  = "us-east-1"
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
}


resource "aws_eip" "eip"{
    vpc = "true"

    tags = {
        Name = "Terraform_eip"
    }
}

resource "aws_instance" "ec2"{
    ami = "ami-0947d2ba12ee1ff75"
    instance_type =  "t2.micro"
    
    tags = {
        Name = "Terraform_ec2"
    }
}

resource "aws_security_group" "allow_tls" {
  name        = "terraform"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    
    cidr_blocks = ["${aws_eip.eip.public_ip}/32"]   # allocating the ip addeds as we do in the security_group (0.0.0.0/0)

    # cidr_blocks = [aws_eip.lb.public_ip/32]
  }
  tags = {
      Name = "Terraform_SG"
  }
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2.id   # which ec2
  allocation_id = aws_eip.eip.id        # which  eip
}
