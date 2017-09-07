#!/bin/bash
export PATH=$PATH:$PWD terraform
TF_VAR_aws_pwd=$PWD terraform plan
TF_VAR_aws_pwd=$PWD terraform apply
#Remove the comment if you want your waf instance to secure the server instance
#ruby config_full_new.rb
