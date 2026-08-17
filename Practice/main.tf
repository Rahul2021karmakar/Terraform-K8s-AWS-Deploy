provider "aws" {
  region  = "ap-south-1"
  profile = "cuddlyduddly"
}

resource "aws_instance" "test-ec2" {
  ami           = "ami-0b40571b9c2387b15"
  instance_type = "t4g.micro"
  key_name      = "cuddly-duddly-dev"
  tags = {
    Name = "terraform-test"
  }
}

