provider "aws" {
    region = "${file("${var.aws_pwd}/region.txt")}"
}
/*Instances launched into default VPC unless specified*/
resource "aws_vpc" "test" {
    cidr_block = "${var.cidr_block_vpc}"
    tags {
      Name = "terrfm_test"
      }  /*Hardcode required value*/
}
resource "aws_route_table" "route" {
    vpc_id = "${aws_vpc.test.id}"
    depends_on = ["aws_internet_gateway.main"]
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.main.id}"
    }
    tags {
        Name = "terrfm-vpc-route-table"   /*Hardcode required value*/
    }
}
/*Based on number of subnets,create route table associations*/
resource "aws_route_table_association" "vpc" {
    subnet_id = "${aws_subnet.main.0.id}"
    route_table_id = "${aws_route_table.route.id}"
}
resource "aws_route_table_association" "vpc-1" {
    subnet_id = "${aws_subnet.main.1.id}"
    route_table_id = "${aws_route_table.route.id}"
}
resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.test.id}"
    tags {
        Name = "terrfm-vpc-igw" /*Hardcode required value*/
    }
}
