provider "aws" {
  region  = "us-east-1"
  access_key = "AKIAIQALPXYK5CCNX2IA"
  secret_key = "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"
}




resource "aws_eip" "Terraform_eip"{
    vpc = "true"

    tags = {
        Name = "Terraform_eip"
    }
}

output "eip" {
    value =  aws_eip.Terraform_eip.public_ip
}


resource "aws_s3_bucket" "Terraform_S3" {
  bucket = "my-tf-test-bucket-00765465465"
  
/*
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  } */
}


output "s3" {
    value =  aws_s3_bucket.Terraform_S3.bucket_domain_name
}