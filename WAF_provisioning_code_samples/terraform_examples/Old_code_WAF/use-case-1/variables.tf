variable "cidr_block_vpc" {
    description = "cidr block for vpcs"
    /*default = "10.1.0.0/16"*/
}
variable "subnet_cidr_blocks" {
    description = "subnet_cidr_blocks seperated by commas"
    /*default = "10.1.1.0/24,10.1.2.0/24"*/
}
variable "aws_pwd"{} /*present working directory to reference files*/
variable "waf_instance_name" {
    description = "Name tag of WAF instance"
}
variable "waf_instance_type" {
  description = "Instance Type of WAF instance"
}
