provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0b20f552f63953f0e"  # Example Ubuntu AMI
  instance_type = "t2.micro"
  
  key_name = "Abhay-1"

  tags = {
    Name = "Terraform-Instance"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
