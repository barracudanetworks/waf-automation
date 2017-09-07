/*Create security groups with the following 3 rules*/
resource "aws_security_group" "waf" {
    vpc_id = "${aws_vpc.test.id}"
    name = "AWS_EC2_WAF_SEC_GROUP-1.0.0" /*Hardcode required value*/

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
      Name = "terraform-aws-ec2-waf-sec-group-1.0.0" /*Hardcode required value*/
    }
}
