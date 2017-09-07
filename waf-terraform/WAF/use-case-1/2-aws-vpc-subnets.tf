/*Create a number of subnets based on count*/
resource "aws_subnet" "main" {
    vpc_id = "${aws_vpc.test.id}"
    count = 2  /*Hardcode required value*/
    cidr_block = "${element(split(",",var.subnet_cidr_blocks),count.index)}"
    tags {
        Name = "terrfm_subnet_${count.index}" /*Hardcode required value*/
    }
}
/*Subnet-1 name will be aws_subnet.main.0 and 2nd will be aws_subnet.main.1 and so on*/
/*Use the corresponding subnet names for route table associations*/
