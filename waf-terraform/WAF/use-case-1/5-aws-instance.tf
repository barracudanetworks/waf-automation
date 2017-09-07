/*Launch the WAF instance and associate with the needed subnet-id and security groups*/
resource "aws_instance" "waf-instance" {
    ami = "ami-5beefd22" /*Hardcode required value*/
    instance_type = "${var.waf_instance_type}"
    key_name = "${aws_key_pair.main.key_name}"
    subnet_id = "${aws_subnet.main.1.id}"
    vpc_security_group_ids = ["${aws_security_group.waf.id}"]
    associate_public_ip_address = true
    tags {
      Name = "${var.waf_instance_name}"
    }
}
