#!/bin/bash
# you have to have the aws command line be installed and authorized
# to get version 11 instances, change the fw10.1 to fw11.0
for region in `aws ec2 describe-regions --output text | cut -f4`
do
  echo $region
  echo BYOL
  aws ec2 describe-images --region $region --filters "Name=name,Values=CudaW*fw10.1*BYOL*" --query 'sort_by(Images, &CreationDate)[].ImageId'
  echo PAYG
  aws ec2 describe-images --region $region --filters "Name=name,Values=CudaW*fw10.1*PAYG*" --query 'sort_by(Images, &CreationDate)[].ImageId'
done
