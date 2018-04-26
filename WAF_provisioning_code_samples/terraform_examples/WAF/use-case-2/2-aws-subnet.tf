/*Structure of imported Subnet*/
/*If CidrBlock and Name tags do not match,Terraform forces a new resource thereby deleting the previous one*/

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${file("${var.aws_pwd}/cidr_block_subnet.txt")}"
  tags {
      Name = "${file("${var.aws_pwd}/subnet_name.txt")}"
  }
}
