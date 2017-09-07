/*Creates an instance of Barracuda WAF*/
resource "aws_instance" "waf-instance" {
    ami = "ami-0b0f9f6b"                          /*Hardcode required value*/
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.main.key_name}"
    subnet_id = "${aws_subnet.main.id}"
    vpc_security_group_ids = ["${aws_security_group.waf.id}"]
    associate_public_ip_address = true
    tags {
      Name = "${var.instance_name}"
    }
}
/*Creates a security group with rules required by the WAF*/
resource "aws_security_group" "waf" {
    vpc_id = "${aws_vpc.main.id}"
    name = "${var.security_group_name}"
    ingress {
        from_port = "8000"
        to_port = "8000"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

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
      Name = "${var.security_group_name}" 
    }
}
