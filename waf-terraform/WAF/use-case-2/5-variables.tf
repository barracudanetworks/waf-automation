/*Instance type of the Barracuda WAF instance*/
variable "instance_type" {
    description = "The type of WAF instance"
}
/*Name tag of the instance*/
variable "instance_name" {
    description = "The Name tag of the WAF instance"
}
variable "aws_pwd"{}
variable "security_group_name" {
  description = "Unique name of the security group"
}
