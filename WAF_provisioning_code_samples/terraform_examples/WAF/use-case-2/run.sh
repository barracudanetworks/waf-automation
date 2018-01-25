#!/bin/bash
#File to run Terraform apply with the given environment variable
export PATH=$PATH:$PWD terraform
TF_VAR_aws_pwd=$PWD terraform plan
TF_VAR_aws_pwd=$PWD terraform apply
