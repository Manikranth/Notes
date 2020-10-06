provider "aws" {
  region  = "us-east-1"
  access_key = "AKIAIQALPXYK5CCNX2IA"
  secret_key = "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"
}


data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["amazon"]


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "instance-1" {
    ami = data.aws_ami.app_ami.id
   instance_type = "t2.micro"
}