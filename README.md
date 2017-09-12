# Enabling DevOps practices to use the Barracuda Web Application Firewall

# Introduction

Organisations are adopting infrastructure as code to be more agile to business requirements. Configuration automation solutions such as Puppet have been leaders in this space and have successfully migrated applications from conventional development practices. At the same time, the challenges that organisations have been facing from external threats has been growing exponentially. The challenge is to enhance proven security best practices to be adopted to the agility of the application development lifecycle. Barracuda Web Application Firewall (WAF) has been a long-standing cloud enabled security solution for application security needs. 
This space will include details about how common DevOps practices/tools can be used with the Barracuda Web Applications Firewall product with primary focus on public cloud platforms like AWS and Microsoft Azure.

# Provisioning and Deployment
### Amazon Web Services
##### Single instance deployments
Ansible: Deploying Barracuda WAF on AWS
Puppet: Deploying Barracuda Web Application Firewall on AWS
Terraform: Deploying Barracuda WAF on AWS
##### CFT for Autoscaling deployments
BYOL Auto Scaling
PAYG Auto Scaling
Metered Auto Scaling
### Microsoft Azure
##### Template based deployments
Ansible: Deploying Barracuda WAF on Azure
Puppet: Deploying Barracuda Web Application Firewall on Azure
# REST API
##### REST API v1
Documentation
##### REST API v3
Documentation[barracuda/ReStApIv3]
# Automation of Configuration Management of the Barracuda WAF
##### Configuration Management using Puppet
AWS - Ruby script to configure a WAF instance on AWS
Azure - Ruby script to configure a WAF instance on Azure
##### Configuration Management using Ansible
Playbook sample for configuring WAF
Ansible playbook yml file for WAF configuration
# Vulnerabiilty Remediation Service
##### Ruby script for connecting to VRS and setting up a scan
AWS - Ruby script for connecting to VRS and setting up a scan for an AWS instance
Azure - Ruby script for connecting to VRS and setting up a scan for an Azure instance
# Workflow Samples
##### Application + Security Lifecycle Management
In this workflow, the objective is to introduce security into the application deployment in a seamless way. REST API can be used to configure the service, link the WAF to Barracuda Cloud control, as well as to enable the advanced security controls. For further security fine tuning, Barracuda VRS can be leveraged. This workflow can be automated using configuration management tools like Puppet, Ansible and Chef. The workflow is shown with a schematic diagram below:
Web App Firewall > DevOps Toolkit for Barracuda WAF > Screen Shot 2017-09-07 at 11.19.23 AM.png
##### Blue/Green testing
The objective of this workflow is to provision parallel setups for application deployment, testing and configuration management. In order to minimize maintenance windows and reduce downtime, production and staging environments are swapped seamlessly to ensure production traffic flows through the most stable and well tested infrastructure.
Web App Firewall > DevOps Toolkit for Barracuda WAF > Screen Shot 2017-09-07 at 11.20.39 AM.png
##### Build, Deploy, Test and Destroy
The objective of this workflow achieves a broader scope of deploying WAF into an application's SDLC. WAF gets deployed just like any other build, gets configured, tested for traffic and security and then gets teared down as part of the build test cycle.
Web App Firewall > DevOps Toolkit for Barracuda WAF > Screen Shot 2017-09-07 at 11.21.15 AM.png


