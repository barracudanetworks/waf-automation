# cudawaf

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with cudawaf](#setup)
    * [What cudawaf affects](#what-cudawaf-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cudawaf](#beginning-with-cudawaf)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module can be used to configure the WAF system. Services, Real servers,
certificates and barracuda cloud control can be configured.

## Setup
`puppet module install puppetlabs-cudawaf`

## To install in a specific environment
`puppet module install puppetlabs-cudawaf --environment=<env-name>`

### Setup Requirements

Installing the gem files:
`gem install typoheus`
`gem install rest-client`

### Examples

To create a Service:

wafservices  { 'WAFSVC-1':
  ensure	=> present,
  name          => 'WAFSERVICE',
  type		=> 'http',
  mask		=> '255.255.255.255',
  ip_address	=> '3.3.3.3',
  port		=> '80',
  group		=> 'default',
  vsite		=> 'default',
  status		=> 'On',
  address_version	=> 'ipv4',
  enable_access_logs => 'Yes',
  svcname => 'ProdService',
	}
}

To create a Real server:

wafservers{ 'WAFSERVER-2':
  ensure => present,
  name => 'server2',
  identifier=> 'IP Address',
  address_version => 'IPv4',
  status => 'In Service',
  ip_address => '8.8.8.8',
  service_name => 'demo_service_13',
  hostname => 'TEST',
  port => '80',
  comments => 'Creating the server'
}

To create a Certificate:

wafcertificates{ 'WAFUPLOADSIGNEDCER-1':
  ensure => present,
  cer_name => 'wafuploadsignedcert1',
  name => 'signedcert1',
  signed_certificate => '/home/wafcertificates/fullchain.pem',
  allow_private_key_export => 'yes',
  type => 'pem',
  key =>'/home/wafcertificates/privkey.pem',
  assign_associated_key => 'no',
  upload => 'signed'
}

To connect the WAF to Barracuda Cloud Control


## Reference

Refer to the documentation for adding information on the REST API:
https://campus.barracuda.com/product/webapplicationfirewall/

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc.

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel
are necessary or important to include here. Please use the `## ` header.
-- INSERT --                                                              
