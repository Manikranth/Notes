provider "aws" {
  region  = "us-east-1"
  access_key = var.subnet_id[0].access_key
  secret_key = var.subnet_id[0].secret_key
}

variable "subnet_id"{    #is used when give the input when you run the code, basscally it wil ask for the "enter value" and place that value in the menction place 
    description = "enter the IP addredd"
    #default = #if there is no data in the terraform.tfvars it take this as it's value 
    #type = string # the value from the terraform.tfvars should be this type
} 



#create VCP
resource "aws_vpc" "terraform_vcp" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform VPC"
    }
}


#Createing Subnet
resource "aws_subnet" "terraform_subnet" {
  vpc_id     = aws_vpc.terraform_vcp.id
  cidr_block = var.subnet_id[1]            # there is where you menction the "var" option with the "terraform name" so that when you input the value it will be applied here.
  availability_zone = "us-east-1a"  

  tags = {
    Name = "terraform subnet"
  }
}