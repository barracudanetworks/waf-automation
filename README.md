# DevOps with Barracuda Web Application Firewall

# Introduction

Organisations are adopting infrastructure as Code to be more agile to business requirements. Configuration automation solutions such as Puppet have been leaders in this space and have successfully migrated applications from conventional development practices. At the same time, the challenges that organisations have been facing from external threats has been growing exponentially. The challenge is to enhance proven security best practices to be adopted to the agility of the application development lifecycle. Barracuda Web Application Firewall (WAF) has been a long-standing cloud enabled security solution for application security needs. [Click here to learn more about the Barracuda Web Application Firewall](https://campus.barracuda.com/product/webapplicationfirewall/) 

![alt](https://www.barracuda.com/assets/img/sections/programs/azure/img_app-security_diagram1.png)


This space will include details about how common DevOps practices/tools can be used with the Barracuda Web Applications Firewall product with primary focus on public cloud platforms like AWS and Microsoft Azure.

# Provisioning and Deployment
### Amazon Web Services
##### Single instance deployments
1. Ansible: [Deploying Barracuda WAF on AWS](https://github.com/barracudanetworks/waf-automation/blob/master/WAF_provisioning_code_samples/ansible_examples/waf_ec2.yml)
2. Puppet: [Deploying Barracuda Web Application Firewall on AWS](https://github.com/barracudanetworks/waf-automation/tree/master/WAF_provisioning_code_samples/puppet_examples/aws/modules/profiles)
3. Terraform: [Deploying Barracuda WAF on AWS](https://github.com/barracudanetworks/waf-automation/tree/master/WAF_provisioning_code_samples/terraform_examples)
##### CFT for Autoscaling deployments
1. [BYOL Auto Scaling](https://campus.barracuda.com/product/webapplicationfirewall/article/WAF/BYOLAutoScaling/)
2. [PAYG Auto Scaling](https://campus.barracuda.com/product/webapplicationfirewall/article/display/BWAFv76/73007159/)
3. [Metered Auto Scaling](https://campus.barracuda.com/product/webapplicationfirewall/article/display/BWAFv76/68361418/)
### Microsoft Azure
##### Template based deployments
1. Ansible: [Deploying Barracuda WAF on Azure](https://github.com/barracudanetworks/waf-automation/tree/master/WAF_provisioning_code_samples/ansible_examples)
2. Puppet: [Deploying Barracuda Web Application Firewall on Azure](https://github.com/barracudanetworks/waf-automation/tree/master/WAF_provisioning_code_samples/puppet_examples/azureinfra)
# REST API
##### REST API v1
[Documentation](https://campus.barracuda.com/product/webapplicationfirewall/article/WAF/RESTAPI/)
##### REST API v3
[Documentation](https://campus.barracuda.com/product/webapplicationfirewall/api) `NEW`

# Vulnerability Remediation Service
##### Ruby script for connecting to VRS and setting up a scan
1. AWS - [Ruby script for connecting to VRS and setting up a scan for an AWS instance](https://github.com/barracudanetworks/waf-automation/blob/master/VRS/ruby-vrs-aws.rb)
2. Azure - [Ruby script for connecting to VRS and setting up a scan for an Azure instance](https://github.com/barracudanetworks/waf-automation/blob/master/VRS/ruby-vrs-azure.rb)
# Workflow Samples
Using the code samples in this repo, organizations can build devops workflows in their networks. The following are some of the devops workflows that can be created:

### 1. Application + Security Lifecycle Management
In this workflow, the objective is to introduce security into the application deployment in a seamless way. REST API can be used to configure the service, link the WAF to Barracuda Cloud control, as well as to enable the advanced security controls. For further security fine tuning, Barracuda VRS can be leveraged. This workflow can be automated using configuration management tools like Puppet, Ansible and Chef. The workflow is shown with a schematic diagram below:

![alt](https://github.com/barracudanetworks/waf-automation/blob/master/images/Screen%20Shot%202017-09-07%20at%2011.19.23%20AM.png)

### 2. Blue/Green testing
The objective of this workflow is to provision parallel setups for application deployment, testing and configuration management. In order to minimize maintenance windows and reduce downtime, production and staging environments are swapped seamlessly to ensure production traffic flows through the most stable and well tested infrastructure.

![alt](https://github.com/barracudanetworks/waf-automation/blob/master/images/Screen%20Shot%202017-09-07%20at%2011.20.39%20AM.png)

### 3. Build, Deploy, Test and Destroy
The objective of this workflow achieves a broader scope of deploying WAF into an application's SDLC. WAF gets deployed just like any other build, gets configured, tested for traffic and security and then gets teared down as part of the build test cycle.

![alt](https://github.com/barracudanetworks/waf-automation/blob/master/images/Screen%20Shot%202017-09-07%20at%2011.21.15%20AM.png)

##### DISCLAIMER: ALL OF THE SOURCE CODE ON THIS REPOSITORY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL BARRACUDA BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOURCE CODE. #####
