**Introduction**

Terraform is an infrastructure as code software by HashiCorp.It allows users to define a datacenter infrastructure in a high level configuration language,from which it can create an execution plan to build the infrastructure in a service provider such as AWS.

**OBJECTIVE** 
To deploy a Barracuda WAF instance in a subnet of a selected VPC.

**Prerequisites**

1) Terraform - Download Terraform for your required OS here - https://www.terraform.io/downloads.html
After that,place the downloaded Terraform software in the working directory.

2) AWS CLI - Installing the AWS CLI - http://docs.aws.amazon.com/cli/latest/userguide/installing.html
3) Make sure your Amazon Web Services credentials file is located in $HOME/.aws/credentials. Terraform by default checks in this location for the credentials file.

This folder contains the following type of files:-
a) .tf - Terraform files to provision and maintain infrastructure
b) .sh - Shell script files,which will be explained later
c) .txt - Text files will be created after running of the init.sh file. These contain the credentials of the user entered details.
d) .tfstate - State files of the terraform resources. Explained later.

Follow the steps to run the program:-
1) chmod +x init.sh
2) sudo ./init.sh - This is to get the vpc-id and subnet-id for the waf to be deployed in. Enter the credentials. Also,enter the name of the key pair to be created to be used with the launched instance.
3)After running this script,you will see a file called "terraform.tfstate". Copy the "lineage" field of that file into the "lineage" field of the file "terraformrefresh.tfstate". The file refresh.sh is used to create an alias command refresh,to allow multiple imports. After you have imported the VPC and Subnet and wish to deploy another instance,run the command "refresh" before you run init.sh again.
4) source refresh.sh - To make the command "refresh" executable.
5) Hardcode the required ami of the instance in the file 3-aws-waf-instance.tf
6) sudo ./run.sh - This file runs the "terraform plan" and "terraform apply" command that is used to provision the resources according to user needs. The command "terraform plan" executes a plan that will show you what the infrastructure will look like after creation. If you wish to edit any details simply terminate and run the script again.

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE.
