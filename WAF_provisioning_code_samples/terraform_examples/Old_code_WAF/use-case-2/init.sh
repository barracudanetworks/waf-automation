#!/bin/bash
#Set environment variable aws_pwd to the present working directory. Used as path name
export PATH=$PATH:$PWD terraform
export TF_VAR_aws_pwd=$PWD
#To create the alias command refresh to refresh the state file
chmod +x refresh.sh
#permission to execute the file run.sh
chmod +x run.sh
#configure aws
aws configure
region=$(aws configure get region)
echo -n $region > region.txt
#Display all VPCs in the selected region with their VPC-ID and Names
echo "Available VPCs:"
aws ec2 describe-tags --filters "Name=resource-type,Values=vpc" "Name=key,Values=Name" --output=text | cut  -f3,5-
echo "Enter the vpc id of the vpc:"
read vpc_id
#Display the information about the selected VPC,used as an I/O error correction
#If the VPC-ID entered does not match with any existing VPC,error returned.
aws ec2 describe-vpcs --vpc-id $vpc_id
#Get the VPC tag Name and stores it in a file
vpc_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$vpc_id" "Name=key,Values=Name" --output=text | cut -f5)
echo -n $vpc_name > vpc_name.txt
#Gets the CidrBlock of the selected VPC and stores it in a file.
cidr_block_vpc=$(aws ec2 describe-vpcs --query "Vpcs[?VpcId == '$vpc_id'].CidrBlock" --output=text)
echo -n $cidr_block_vpc > cidr_block_vpc.txt
#Import the selected VPC
terraform import aws_vpc.main $vpc_id
#Display all Subnets in the selected VPC
echo "Subnets in the given VPC:"
#Get the subnet id and name tags of all subnets in the selected VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[].[SubnetId,Tags[?Key == `Name`].Value[]]' --output=text > all_subnets.txt
#To make the output more readible,contents are stored in a text file
awk 'ORS=NR%2?" ":"\n"' all_subnets.txt
echo -n "Choose the subnet id:"
read subnet_id
#Remove the created file. Not required anympre
rm all_subnets.txt
#Display the information about the selected subnet,used as an I/O error correction
#If the Subnet-ID entered does not match with any existing subnets,error returned.
aws ec2 describe-subnets --filters "Name=subnet-id,Values=$subnet_id"
#Gets the Name tag of the Subnet
subnet_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$subnet_id" "Name=key,Values=Name" --output=text | cut -f5)
echo -n $subnet_name > subnet_name.txt
#Get the CidrBlock of the selected Subnet
cidr_block_subnet=$(aws ec2 describe-subnets --query "Subnets[?SubnetId=='$subnet_id'].CidrBlock" --output=text)
echo -n $cidr_block_subnet > cidr_block_subnet.txt
terraform import aws_subnet.main $subnet_id
#Create a new key pair
echo -n "Enter name of key pair to be created:"
read key_pair_name
#Store the key pair name in a file
echo -n $key_pair_name > key_pair_name.txt
ssh-keygen -f $key_pair_name
#Store the public key of the key pair in a file.
cat $key_pair_name.pub > public_key.txt
#This file is not required. Remove
rm $key_pair_name.pub
