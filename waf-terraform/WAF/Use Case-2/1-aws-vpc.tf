/*AWS Provider*/
provider "aws" {
  region = "${file("${var.aws_pwd}/region.txt")}"
}
/*Structure of imported VPC*/
/*If CidrBlock and Name tag does not match with the imported resources,a new resource is created,deleting the previous one*/

resource "aws_vpc" "main" {
  cidr_block = "${file("${var.aws_pwd}/cidr_block_vpc.txt")}" /*Change the path according to your needs*/
  tags {
      Name = "${file("${var.aws_pwd}/vpc_name.txt")}"
  }
}
