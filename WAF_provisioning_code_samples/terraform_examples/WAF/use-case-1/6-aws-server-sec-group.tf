/*Set the server security groups*/
resource "aws_security_group" "terraform-server" {
    vpc_id = "${aws_vpc.test.id}"
    name = "terraform-server-sec-group-1.0.0" /*Hardcode required value*/

    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = "443"
        to_port = "443"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "terraform-server-sec-group-1.0.0" /*Hardcode required value*/
    }
}
