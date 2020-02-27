### About this deployment

This deployment will provision a BYOL instance of the Barracuda Web Application Firewall in the us-west-2 region

### Important Note
The AMI ID is hard coded in the .tf file and may need to be changed to pick up the latest image for the desired license option (BYOL, PAYG or Metered) from the AWS marketplace.

### Pre-Requisites

1. AWS Access key and Access secret with valid permissions to provision ec2 instances from the AWS market place 
2. VPC with atleast 1 subnet, internet gateway and a functioning route table
3. EC2 Key pair
4. EC2 Security Group
5. Terraform should be installed on the computer on which the code is run

### Usage

Step 1

Create environment variables for the AWS access key and access secret

`$ export AWS_ACCESS_KEY_ID="anaccesskey"`

`$ export AWS_SECRET_ACCESS_KEY="asecretkey"`


Step 2

From the directory in which the file exists:

1. To download the AWS resource (Details: https://www.terraform.io/docs/providers/aws/index.html)

`$ terraform init`

2. To create a plan for the provisioning

`$ terraform plan -out <plan name>`

3. To apply the plan

`$ terraform apply <plan name>`

4. To destroy the deployment

`$ terraform destroy`

### Additional info
The code allows for increasing the number of the instances by specifying a value for the count attribute. For example count = "5" will provision 5 instances.

### Next steps
Once the unit is provisioned, you may continue with the configuration by following step6 from this link: https://campus.barracuda.com/product/webapplicationfirewall/doc/41104663/barracuda-cloudgen-waf-deployment-and-quick-start-guide-for-amazon-web-services



