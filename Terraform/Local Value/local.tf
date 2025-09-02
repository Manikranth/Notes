provider "aws" {
  region  = "us-east-1"
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
}
 locals {
     test = {
         Owner = "Devops Team"
         service = "backend"
     }
 }


 resource "aws_instance" "prod" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   
   tags = local.test

 }

 resource "aws_instance" "dev" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   
   tags = local.test

 }


 resource "aws_ebs_volume" "ebs" {
   availability_zone = "us-east-1a"
   tags = local.test 
 }