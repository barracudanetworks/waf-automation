# DevOps with Barracuda Web Application Firewall

# Introduction

Organisations are adopting infrastructure as code to be more agile to business requirements. Configuration automation solutions such as Puppet have been leaders in this space and have successfully migrated applications from conventional development practices. At the same time, the challenges that organisations have been facing from external threats has been growing exponentially. The challenge is to enhance proven security best practices to be adopted to the agility of the application development lifecycle. Barracuda Web Application Firewall (WAF) has been a long-standing cloud enabled security solution for application security needs. [Click here to learn more about the Barracuda Web Application Firewall](https://campus.barracuda.com/product/webapplicationfirewall/) 

This space will include details about how common DevOps practices/tools can be used with the Barracuda Web Applications Firewall product with primary focus on public cloud platforms like AWS and Microsoft Azure.

# Provisioning and Deployment
### Amazon Web Services
##### Single instance deployments
Ansible: [Deploying Barracuda WAF on AWS](https://github.com/barracudanetworks/waf-automation/blob/master/waf-ansible/waf_ec2.yml)
Puppet: Deploying Barracuda Web Application Firewall on AWS
Terraform: Deploying Barracuda WAF on AWS
##### CFT for Autoscaling deployments
1. [BYOL Auto Scaling](https://campus.barracuda.com/product/webapplicationfirewall/article/WAF/BYOLAutoScaling/)
2. [PAYG Auto Scaling](https://campus.barracuda.com/product/webapplicationfirewall/article/display/BWAFv76/73007159/)
3. [Metered Auto Scaling](https://campus.barracuda.com/product/webapplicationfirewall/article/display/BWAFv76/68361418/)
### Microsoft Azure
##### Template based deployments
Ansible: Deploying Barracuda WAF on Azure
Puppet: Deploying Barracuda Web Application Firewall on Azure
# REST API
##### REST API v1
[Documentation](https://campus.barracuda.com/product/webapplicationfirewall/article/WAF/RESTAPI/)
##### REST API v3
[Documentation]
# Automation of Configuration Management of the Barracuda WAF
##### Configuration Management using Puppet
1. AWS - Ruby script to configure a WAF instance on AWS
2. Azure - Ruby script to configure a WAF instance on Azure
##### Configuration Management using Ansible
##### Playbook sample for configuring WAF
1. Ansible playbook yml file for WAF configuration
# Vulnerabiilty Remediation Service
##### Ruby script for connecting to VRS and setting up a scan
1. AWS - Ruby script for connecting to VRS and setting up a scan for an AWS instance
2. Azure - Ruby script for connecting to VRS and setting up a scan for an Azure instance
# Workflow Samples
##### Application + Security Lifecycle Management
In this workflow, the objective is to introduce security into the application deployment in a seamless way. REST API can be used to configure the service, link the WAF to Barracuda Cloud control, as well as to enable the advanced security controls. For further security fine tuning, Barracuda VRS can be leveraged. This workflow can be automated using configuration management tools like Puppet, Ansible and Chef. The workflow is shown with a schematic diagram below:
![alt](https://github.com/barracudanetworks/waf-automation/blob/master/images/Screen%20Shot%202017-09-07%20at%2011.19.23%20AM.png)
##### Blue/Green testing
The objective of this workflow is to provision parallel setups for application deployment, testing and configuration management. In order to minimize maintenance windows and reduce downtime, production and staging environments are swapped seamlessly to ensure production traffic flows through the most stable and well tested infrastructure.
![alt](https://github.com/barracudanetworks/waf-automation/blob/master/images/Screen%20Shot%202017-09-07%20at%2011.20.39%20AM.png)
##### Build, Deploy, Test and Destroy
The objective of this workflow achieves a broader scope of deploying WAF into an application's SDLC. WAF gets deployed just like any other build, gets configured, tested for traffic and security and then gets teared down as part of the build test cycle.
![alt](https://github.com/barracudanetworks/waf-automation/blob/master/images/Screen%20Shot%202017-09-07%20at%2011.21.15%20AM.png)


