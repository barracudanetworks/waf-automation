**Introduction**

Terraform is an infrastructure as code software by HashiCorp.It allows users to define a datacenter infrastructure in a high level configuration language,from which it can create an execution plan to build the infrastructure in a service provider such as AWS.

**Objective**

To deploy a Barracuda WAF instance in a newly created infrastructure.

**Prerequisites**

1) Terraform - Download Terraform for your required OS here - https://www.terraform.io/downloads.html
After that,place the downloaded Terraform software in the working directory.

2) AWS CLI - Installing the AWS CLI - http://docs.aws.amazon.com/cli/latest/userguide/installing.html
3) Make sure your Amazon Web Services credentials file is located in $HOME/.aws/credentials. Terraform by default checks in this location for the credentials file.

The program creates the following infrastructure(Configuration files of the corresponding resources in brackets):-
1) A Virtual Private Cloud(VPC) (1-aws-vpc.tf)
2) A Route Table and Internet Gateway for this VPC(1-aws-vpc.tf)
3) Subnets in the VPC along with their route table associations(2-aws-vpc-subnets.tf)
4) Security Group for the WAF (3-aws-ec2-waf-sg.tf)
5) Key Pair with the user-entered name (4-aws-key-pair.tf)
6) A server instance of choice (6-aws-server-sec-group.tf)
7) Security Group for the server instance (7-aws-server-instance.tf)
8) And finally,the Barracuda WAF instance to be deployed in this infrastructure.(5-aws-instance.tf)

**Procedure**

This program deploys the Barracuda WAF in the newly created infrastructure.
1) In all the .tf files,hardcode the required name tags of all the resources. Make sure to keep unique VPC,WAF instance,subnet names.
2) In the file 2-aws-vpc-subnets.tf,change the variable "count" to the number of subnets you wish to create.
3) The default numbering starts from 0,so if there are 2 subnets,their names will be aws_subnet.main.0,aws_subnet.main.1.
4) Using the already existing config for the route table association in the file 1-aws-vpc.tf,copy and paste or comment out(or even delete) depending on the number of subnets created. (/*This is a comment in terraform files*/)
The number of "route_table_association" resources should be equal to the number of subnets created,i.e,one for each subnet.
5) Hardcode the subnet and ami of the Barracuda WAF to be deployed. In the "subnet_id" field change put the index of the subnet in place of the *. Eg:- subnet_id = "${aws_subnet.main.*.id}" Replace * with the required subnet reference.
6) chmod +x init.sh.
7) sudo ./init.sh
8) Enter the VPC and Subnet CIDR blocks to be created. Subnet CIDR blocks need to be entered by seperating them with commas.
Eg:- 10.1.1.0/24,10.1.2.0/24
9)Enter the WAF instance name and type.
10) sudo ./run.sh. This will run "terraform plan". Take a look at what the end result of the infrastructure will look like. To make changes simply stop the script and run it again after the necessary changes have been made."terraform apply" is executed immediately after "terraform plan" so repeat steps 8 and 9,and the infrastructure will be created.

If you wish to secure the server with the created WAF instance,in the config_full_new.rb file,do the following:-
1) Change the "Values" field in lines 10,13,16 to the name of the WAF instance. Make sure there are no ambiguous instances,i.e,instances having the same name.
2) Change the "Values" field in line 28 to the name of the server instance to be secured.
3) ruby config_full_new.rb

DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE.
