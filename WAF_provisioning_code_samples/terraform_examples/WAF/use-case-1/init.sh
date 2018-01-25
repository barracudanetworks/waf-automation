#!/bin/bash
#Script to run terraform apply and ruby script
export PATH=$PATH:$PWD terraform
export TF_VAR_aws_pwd=$PWD
chmod +x run.sh
#configure
aws configure
#Get region
region=$(aws configure get region)
echo -n $region > region.txt
echo "Enter key pair name to be created"
read key_pair_name
echo -n $key_pair_name > key_pair_name.txt
#Create key pair using entered key pair name
ssh-keygen -f $key_pair_name
cat $key_pair_name.pub > public_key.txt
#This file is not required anymore
rm $key_pair_name.pub
