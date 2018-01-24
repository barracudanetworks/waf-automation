# Automating Application Security with Barracuda WAF and Puppet on AWS

## Introduction
Barracuda Web Application Firewall provides comprehensive based protection for applications deployed in physical, virtual, or public cloud environments. 
Puppet Enterprise delivers a unified platform that allows you to both enforce the desired state of your configurations and automatically remediate any unexpected changes, and to automate ad hoc tasks across infrastructure and applications.
Amazon Web Services offers reliable, scalable, and inexpensive cloud computing services.

![alt text](https://github.com/barracudanetworks/waf-automation/blob/master/aws-puppet-waf-hands_on_lab/Screen%20Shot%202018-01-24%20at%2010.06.57%20AM.png)

## Before you begin
Before Importing the CFTs subscribe to the following EC2 images in the AWS marketplace: https://aws.amazon.com/marketplace/?ref=csl_cnslhome_softprods_mphp
 
1.	EC2 Images to subscribe: 
Puppet Enterprise (PAYG): https://aws.amazon.com/marketplace/pp/B071YVSBQW?qid=1515932562950&sr=0-1&ref_=srh_res_product_title

Ubuntu 16.04 LTS - Xenial (HVM): https://aws.amazon.com/marketplace/pp/B01JBL2M0O?qid=1515932601469&sr=0-1&ref_=srh_res_product_title


2.	Check if you can login to vrs.barracudanetworks.com account with the email address provided by Barracuda Networks
 
3.	Create an SSH key pair
For ease of use, create one SSH key pair and use in all CFTs.  

For instructions on how to create a key pair, please visit: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair

If you are going to use Putty to connect to your ec2 instance, please follow the instructions mentioned in this article to prepare your system: https://linuxacademy.com/howtoguides/posts/show/topic/17385-use-putty-to-access-ec2-linux-instances-via-ssh-from-windows
 
4.	Download the CFTs
https://github.com/barracudanetworks/waf-automation/tree/master/aws-puppet-waf-hands_on_lab/cft_files

Note: The CFT files used in this lab is designed to work in AWS regions in US West i.e. us-west-1, us-west-2.

## General Note

•	Use AWS IAM shared key and token and place it in the home directory of the user

•	Create at least one SSH Key pair in the AWS region where the stack will be deployed

•	Download the SSH key to your local computer and lower the permission for the key file.


## Setting up the environment

This step is divided into two sections i.e. Section A and Section B

Section A: Launching the Puppet Master and Agents

This section of the lab will be used to cover the launch of the Puppet ecosystem which will be used for the demo.

Once the Puppet Environment CFT is imported :

## Configuring the EC2 instance of the Puppet Master 

Note: Do not change the Hostname: If you wish to change the hostname, follow the instructions mentioned here: 
https://puppet.com/docs/pe/2017.2/ami_intro.html#changing-the-masters-hostname-and-regenerating-certificates

Checking if the services are up:

``` bash
/opt/puppetlabs/aws/bin/check_status.sh --wait
check_status.sh: Configuring Puppet Enterprise services.......

This can take up to 7-8 minutes as the services get configured after which you should get an output such as below:

check_status.sh: Configuring Puppet Enterprise services...............
check_status.sh: Puppet Enterprise is fully active.
check_status.sh: Puppet Enterprise console (username "admin") is available at:
  https://ec2.compute.amazonaws.com
check_status.sh: To set the console password and obtain access, run:
sudo /opt/puppetlabs/aws/bin/set_console_password.sh
```

## Setting the password 

```bash
sudo /opt/puppetlabs/aws/bin/set_console_password.sh
```

## Web Login

https://<public_ip> : Username is admin and password is the console password set with the above command
Creating a new environment

Path: /etc/puppetlabs/code/environments/

## Cloning the code
Go to /home/puppetadmin
#### git clone https://github.com/barracudanetworks/waf-automation.git

## Installing the AWS Module
Path: /etc/puppetlabs/code/environments/production/

```puppet
puppet module install barracuda-cudawaf –environment=production
```
## Moving the code to the Puppet environment
```bash
sudo cp –r /home/puppetadmin/waf-automation/aws-puppet-waf-hands_on_lab/* /etc/puppetlabs/code/environments/production/modules/cudawaf/manifests/
```
## Handling Dependencies

### Install Typhoeus
```bash
/opt/puppetlabs/bin/puppetserver gem install typhoeus
```

### Install  rest-client
```bash
yum install gcc
yum install gcc-c++
/opt/puppetlabs/bin/puppetserver gem install rest-client -v 1.8.0
```
### Elevate permissions for the gemspec files

```bash
chmod 777 /opt/puppetlabs/puppet/lib/ruby/gems/2.0.1/specifications/*
```

## Configure agent-specified node rules as necessary to match the hostnames of the nodes.

Set up the /opt/puppetlabs/code/environments/production/manifests/site.pp

```puppet
node <agenthostname>
{
include cudawaf::dependency
}

node <waf>
{
include cudawaf::waf_configuration
}
```

## Configuring the Puppet Agent
Configuring the host name resolution for the Puppet Master
Path: /etc/hosts
Use a text editor.
Create a local hosts entry to point the hostname of the Puppet Master to the Private ip address

## Installing puppet on the agent
curl –kv puppetmaster-ip:8140/packages/current/install.bash | sudo bash

## Section B: Launching the Production Network

This section of the lab will be used to launch the base network for workflow labs that will be covered during the training.

## Important note:

•	Use AWS IAM shared key and token and place it in the home directory of the user

•	Create at least one SSH Key pair in the AWS region where the stack will be deployed

•	Download the SSH key to your local computer and lower the permission for the key file.

•	Changing the permissions for the SSH private key: 

•	# chmod 400 <privatekey.pem>

•	The firmware version on the Barracuda Web Application Firewall should be v9.1.1.x


### Stack Creation
Launch Parameters: Choose the default settings.
### WAF recommended instance size: M4 Large

There are 6 Private Subnets in the VPC. These subnets initiate outbound traffic through a NAT gateway. 
Use Private Subnets 3 and 4 for the WordPress web tiers
Use Private Subnets 5 and 6 for the RDS (Create the RDS DB Subnet Group with these subnets)

## Setting up the DB Subnet Group (To install WP)

RDS is used to serve as the DB for the WordPress Application. DB subnet group is configured in this step.
Setting up WordPress

Import the 3rd CFT wpstack.template
Note: Make sure the DB Password is an alphanumeric string.
Note: This stack creation process takes about 30 minutes to complete.

## Barracuda Web Application Firewall

1.	Login Details: http://<publicip>:8000/
 
2.	Username: admin

3.	Password: <EC2 instance ID for this node>


Step-1: Accept the End User License Agreement

Step-2: Login

Summary
In this lab, a Puppet ecosystem comprising a Puppet Master and two Ubuntu based agent nodes were configured in addition to setting up a base network with a different VPC. 

## About the Barracuda WAF Puppet Module

The following features can be configured using this module:
1.	Service
A Virtual Service is a combination of a Virtual IP (VIP) address and a TCP port, which listens and directs the traffic to the intended Service. The resource type for this feature is "cudawaf_service".
2.	Server
A server object can be used to configure the networking information of the back-end server to be hosted on the Barracuda Web Application Firewall. Multiple real servers can be added and configured to load balance the incoming traffic for a Service. The resource type for this feature is "cudawaf_server".
3.	Certificates
A signed certificate is a digital identity document that enables both server and client to authenticate each other. Certificates are used with HTTPS protocol to encrypt secure information transmitted over the internet. A certificate can be generated or procured from a third-party Certificate Authority (CA). The resource type for this feature is "cudawaf_certificate".
Generated certificates can be self-signed or signed by a trusted third-party CA. A certificate contains information such as user name, expiration date, a unique serial number assigned to the certificate by a trusted CA, the public key, and the name of the CA that issued the certificate.
4.	Cloud control 
A comprehensive cloud-based service that enables administrators to monitor and configure multiple Barracuda Networks products from a single console. The resource type for this feature is "cudawaf_cloudcontrol".
5.	Rule Group
Rules are used to configure content-aware switching over incoming web traffic. Rules help analyze an HTTP request headers to make load balancing and caching policy decisions. The resource type for this feature is “cudawaf_rule_group”
6.	Rule-Group-Server  
A rule group server object can be used to configure the networking information of the back-end server to be hosted on the Barracuda Web Application Firewall. Multiple real servers can be added and configured to load balance the incoming traffic for a rule group. The resource type for this feature is “cudawaf_rule_group_server”

7.	Security Policy 
A Security Policy determines what action to take when one or more of the rules match the request. All security policies are global and can be shared among multiple Services configured on the Barracuda Web Application Firewall. The resource type for this feature is “cudawaf_security_policy”



The detailed documentation on each of these REST API end points can be found here: Barracuda Web Application REST API v3

## Puppet Manifest for this Lab

The file waf_configuration.pp file includes the resource types shown below. Examples of different kinds of configuration using Puppet manifests:

### Create a SSL certificate
```puppet
 cudawaf_certificate { 'selfsigned_cert':
      ensure => present,
      name  => 'testcert',
      allow_private_key_export =>'Yes',
      city   =>'san_franscisco,
      common_name=> 'puppet.labs.com',
      country_code => 'US',
      curve_type => 'secp256r1',
      key_size => 1024,
      key_type => 'rsa',
      organization_name => 'techkaizen.net',
      organization_unit => 'devops',
      state => 'california',
    }
```
### Create a HTTPS service
```puppet
cudawaf_service { 'https_service':
      ensure        => present,
      name          => 'Prod_App',
      type          => 'https',
      ip_address    => '10.36.73.245',
      port          =>  443,
      certificate   => 'testcert',
      group         => 'default',
      vsite         => 'default',
      status        => 'On',
      address_version => 'IPv4',
      comments      => 'This is the production service for the lab',
    }
```
### Create the backend server
```puppet
cudawaf_server { 'http_backend':
      ensure => present,
      name => 'ALB_backend',
      identifier => 'IP Address',
      address_version => 'IPv4',
      status => 'In Service',
      ip_address => '5.5.5.5',
      hostname => '',
      service_name => 'httpsApp1',
      port => 80,
      comments => 'Creating the server'
    }

```
### Connect WAF to Barracuda Cloud Control
```puppet
  cudawaf_cloudcontrol { 'WAFCloudControlSettings':
      ensure         => present,
      connect_mode   => 'cloud',
      state          => 'connected',
      username       => 'customer_account@example.com',
      password       => 'xxxxxxxx'
    }
```
## Custom Facts for the Barracuda Web Application Firewall

These facts are obtained by the agent by connecting to the remote WAF unit
•	Firmware version
•	Serial
•	Hostname
•	Time Zone
•	Model
•	Product Type

## Puppet Device

The Puppet Agent works as a proxy system to connect and apply the manifest on the WAF.

The functions of the Puppet Device subcommand are as follows:

•	Performs the certificate authentication for the WAF nodes

•	Retrieves Facter “facts” from the WAF nodes

•	Sends the facts to the Puppet Master

•	Retrieves the catalog and applies on the WAF node


Sample “device.conf” file

```bash
[waf-1]
   type cudawaf
   url http://admin:<password>@<ip_address>:8000/
```
## Command to run on the agent:

1.	For help
```puppet
puppet help device
```

2.	To run the puppet device 

```puppet
puppet device –v --user=root
```


## Command to run on the master:
```puppet
puppet cert sign <waf_name as mentioned in the device.conf, for e.g waf-1>
```

## Reference Links

Barracuda WAF Auto Scaling CFT for “Pay As You Go” instances: https://aws.amazon.com/marketplace/pp/B014GEC526

Barracuda WAF REST API: https://campus.barracuda.com/product/webapplicationfirewall/api

Barracuda VRS: https://campus.barracuda.com/product/vulnerabilityremediationservice/

Barracuda WAF AWS Quick Start Guide: https://campus.barracuda.com/product/webapplicationfirewall/doc/28967064/amazon-web-services/

For support: aravindan@barracuda.com



