provider "aws" {
  region  = "us-east-1"
  access_key = "AKIAIQALPXYK5CCNX2IA"
  secret_key = "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"
}

resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0dba2cb6798deb6d8"
  instance_type = "t2.micro"
  key_name = "Terraform"

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y nginx1.12",
            "systemctl start nginx1"
        ]
    }

    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("./Terraform.pem")
        host = self.public_ip
    }
}