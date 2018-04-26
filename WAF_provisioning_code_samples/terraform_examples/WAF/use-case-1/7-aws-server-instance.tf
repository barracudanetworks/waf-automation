/*Launch a Bitnami LAMP server*/

resource "aws_instance" "server-instance" {
    ami = "ami-4c60072c" /*Hardcode required value*/
    instance_type = "m4.large" /*Hardcode required value*/
    key_name = "${aws_key_pair.main.key_name}"
    subnet_id = "${aws_subnet.main.0.id}"
    vpc_security_group_ids = ["${aws_security_group.terraform-server.id}"]
    associate_public_ip_address = true
    tags {
      Name = "terraform-ec2-server-instance-1.0.0" /*Hardcode required value*/
    }
}
