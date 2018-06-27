### Introduction
Automating the management of network devices is extremely crucial in agile environments and Puppet modules can be used build on the existing framework using the Puppet Device feature to provide support for administering the Barracuda WAF.

There is no need to install an agent on the WAF with this approach, and takes advantage of the Puppet Device subcommand that’s operated from a standalone Puppet Agent that communicates with the Barracuda WAF REST API v3.

Barracuda WAF can be configured to process traffic for a Web Application, block malicious traffic, Load balance backend servers etc, using this module.

Puppet bridges the gap between an UI driven management process and a script driven API invocation and provides some inherent benefits that are part of the Puppet Enterprise suite to the forefront for a barracuda WAF administrator.

This includes querying the WAF for custom facts using the Facter daemon, using the Puppet resource subcommand to query the WAF for a particular piece of configuration.

Here, we will explain the process of installing the cudawaf module, configuring the connectivity and using Puppet manifests to manage the WAF.

The Puppet device subcommand is a feature in Puppet that allows managing devices that cannot install Puppet agents on themselves.

The WAF units are managed through intermediate proxies which are actually Agents connected to the Puppet Master.
The agent has the certificate for the WAF unit to be managed and authenticates on behalf of the WAF to apply the catalog rendered from the Puppet master. 

### About the Puppet module for Barracuda WAF
This module enables management of the Barracuda Web Application Firewall using Puppet. The following features can be configured using this module:

Virtual Service:  A Virtual Service is a combination of a Virtual IP (VIP) address and a TCP port, which listens and directs the traffic to the intended Service. The resource type for this feature is "cudawaf_service".

Real Server: A server object can be used to configure the networking information of the back-end server to be hosted on the Barracuda Web Application Firewall. Multiple real servers can be added and configured to load balance the incoming traffic for a Service. The resource type for this feature is "cudawaf_server".

Rule Group: A comprehensive cloud-based service that enables administrators to monitor and configure multiple Barracuda Networks products from a single console. The resource type for this feature is "cudawaf_cloudcontrol".

Rule Group Server: A rule group server object can be used to configure the networking information of the back-end server to be hosted on the Barracuda Web Application Firewall. Multiple real servers can be added and configured to load balance the incoming traffic for a rule group. The resource type for this feature is “cudawaf_rule_group_server”.

Security Policy: A Security Policy determines what action to take when one or more of the rules match the request. All security policies are global and can be shared among multiple Services configured on the Barracuda Web Application Firewall. The resource type for this feature is “cudawaf_security_policy".

Certificates: A signed certificate is a digital identity document that enables both server and client to authenticate each other. Certificates are used with HTTPS protocol to encrypt secure information transmitted over the internet. A certificate can be generated or procured from a third party Certificate Authority (CA). The resource type for this feature is "cudawaf_certificate". Generated certificates can be self-signed or signed by a trusted third-party CA. A certificate contains information such as user name, expiration date, a unique serial number assigned to the certificate by a trusted CA, the public key, and the name of the CA that issued the certificate.

Cloud Control: A comprehensive cloud-based service that enables administrators to monitor and configure multiple Barracuda Networks products from a single console. The resource type for this feature is "cudawaf_cloudcontrol".

### Using the Module

To download the module, use the following command:

`puppet module install barracuda/cudawaf`

The default location for the module on the Puppet Master is:

`/etc/puppetlabs/code/environments/production/modules/`

For installing the module in a specific environment, use the following command:

`puppet module install barracuda/cudawaf –environment=<env name>`


You may also access the Barracuda Networks github account, to get the development release for the module. With this approach, please ensure that you rename the module upon downloading to “cudawaf”.

### Important Note
This module can configure Barracuda WAF units running firmware version 9.1.2+. If you are running a previous version, upgrade the firmware, before using the module.

This Puppet Module has been tested in an environment comprising of Linux nodes and hence the commands mentioned in this article are specific to Linux. The OS used on the Puppet Master was CentOS 7 and Ubuntu16.04. For the agents, Ubuntu 16.04 and 14.04 have been tested. Having said that, the module is OS agnostic and should work fine on all platforms running ruby.

The commands mentioned here are for the Puppet Master have been tested on Puppet Enterprise v2017.1.1+

For using the Cloud Control resource type, its important to have a registered account on Barracuda Cloud Control with permissions for appilance control. For more details about the Barracuda Cloud Control, visit the campus documentation.

### Handling Dependencies
Handling dependencies is critical to work with the module. We need to install the dependencies on both the master and the agents before running the puppet commands. 

Handling dependencies on the Master

Install typhoeus v1.3.0 and rest-client v1.8.0

`/opt/puppetlabs/bin/puppetserver gem install typhoeus –v 1.3.0`

`/opt/puppetlabs/bin/puppetserver gem install rest-client –v 1.8.0`

Also, install the gems using the puppet agent gem binary:

`/opt/puppetlabs/puppet/bin/gem install typhoeus –v 1.3.0`

`/opt/puppetlabs/puppet/bin/gem install rest-client –v 1.8.0`

Changing the permissions for the gemspec files
In some cases, external dependencies can cause errors such as "Error in retreiving resource statement" on the Puppet Agent before applying the catalog. Increasing read and execute permissions to the gemspec on the master can help solve this problem.

Default Location of the ‘gemspec’ files

`/opt/puppetlabs/puppet/lib/ruby/gems/2.0.1/specifications`

To change permissions:

`chmod 777 rest-client-1.8.0.gemspec`
`chmod 777 typhoeus-1.*`

Please note: After you are changing permissions, please remember to restart the puppetserver daemon.

`/opt/puppetlabs/bin/puppetserver stop`

`/opt/puppetlabs/bin/puppetserver start`

Handling dependencies on the Puppet Agent

The best way to handle these is to use the 'Package' resource and run the puppet agent command on the target node. Sample manifest of the Package resource:

```puppet
package { 'typhoeus' :
  ensure => present,
  provider => 'puppet_gem',
}
  package { 'rest-client' :
  ensure => '1.8.0',
  provider => 'puppet_gem',
}
```

This manifest can be uploaded to the manifests directory in the cudawaf module. Please note that this directory has to be manually created in the module. For example,

`mkdir /etc/puppetlabs/code/environments/production/modules/cudawaf/manifests/`

Setting up the communication channel on the agent
To use the module, first configure a Puppet agent that is able to run puppet device. This agent will be used to act as a "proxy system" for the puppet device subcommand. 

Create a ‘device.conf’ file on the Puppet Agent node
The location of the file is:

`/etc/puppetlabs/puppet/device.conf`

device.conf is organized in INI-like sections, with one section per device: 
Example "device.conf" file

```puppet
[waf-1]
   type cudawaf
   url http://admin:<password>@<ip_address>:8000/
```

The name of each section should be the name that will be used with Puppet device to access the device.

The body of the section should contain a type directive (use cudawaf) and a url directive (which should be an HTTP URL pointing to port 8000 to the device’s interface, typically the WAN interface).

### Command to run puppet device

To connect and configure the Barracuda WAF from the Puppet Agent, use the Puppet Device subcommand. The command to run is as follows:

`puppet device -v --user=root`

This command retrieves the credentials configured in the `/etc/puppetlabs/puppet/device.conf` file and sends the information to the Puppet Master to retrieve the Puppet Catalog, containing the instructions for configuring the Barracuda WAF.

After the successful application of the catalog, you should see the verbose output in the terminal about the resources getting created.

You may login to the Barracuda WAF web interface to verify if the configuration has been updated as per the manifest.

