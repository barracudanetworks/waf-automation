variable "waf_instance_tag" {
  default = {
    "0" = "cuda_waf_1"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "waf_instance" {
  ami                         = "ami-af0932cf"
  count                       = "1"
  instance_type               = "m4.large"
  key_name                    = "devops.pem"
  subnet_id                   = "subnet-ad83d2ca"
  vpc_security_group_ids      = ["sg-3cda1d44"]
  associate_public_ip_address = "true"

  tags = {
    "Name" = "${lookup(var.waf_instance_tag, count.index)}"
  }
}
