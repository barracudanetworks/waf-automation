# Introduction

This repository contains information about REST API support for Barracuda WAF and Barracuda WAF-As-A-Service and code samples to show how to use these APIs.

# REST API

##### REST API v3
[Documentation](https://campus.barracuda.com/product/webapplicationfirewall/api) `NEW`

# Automation Workflow
Using the code samples in this repo, organizations can build devops workflows. The following are some of the devops workflows that can be created:

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
