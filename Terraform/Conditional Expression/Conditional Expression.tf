provider "aws" {
  region  = "us-east-1"
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
}

 variable "test" {}

 resource "aws_instance" "dev" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   count = var.test == true ? 1 : 0
 }


 resource "aws_instance" "prod" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.large"
    count = var.test == false ? 1 : 0
 }