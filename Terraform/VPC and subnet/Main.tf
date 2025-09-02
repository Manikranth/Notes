provider "aws" {
  region  = "us-east-1"
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
}


resource "aws_vpc" "terraformvcp" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Prod-VPC"
    }
}
resource "aws_subnet" "terraformsubnet" {
  #vpc_id     = <resource>.<resource_name in the terraqform>.id
  vpc_id     = aws_vpc.terraformvcp.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod_subnet"
  }
}




# resource "aws_instance" "Test_terraform" {
#   ami           = "ami-00514a528eadbc95b"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "Terraform"
#   }
#   }

# resource "aws_instance" "Test_terraformtwo" {
#   ami           = "ami-00514a528eadbc95b"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "Terraform - 2"
#   }
#   }

#  resource "<provider>_<resource_type>" "name" {
#     config options......
#     key = "value"
#     Key = "value 2"
# }