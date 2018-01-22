class cudawaf::waf_configuration {

# This resource type creates a self signed certificate which will be eventually bound with a service

    cudawaf_certificate { 'selfsigned_cert':
      ensure => present,
      name  => 'testcert',
      allow_private_key_export =>'Yes',
      city   =>'san_franscisco',
      common_name=> 'puppet.labs.com',
      country_code => 'US',
      curve_type => 'secp256r1',
      key_size => 1024,
      key_type => 'rsa',
      organization_name => 'techkaizen.net',
      organization_unit => 'devops',
      state => 'california',
    }
# This resource type creates a HTTPS service using the certificate created above

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

# This resource type creates a server under the HTTPS service. Replace the hostname with your specific ALB's FQDN

    cudawaf_server { 'http_backend':
      ensure => present,
      name => 'ALB_backend',
      identifier => 'Hostname',
      status => 'In Service',
      hostname  => 'www.barracuda.com',
      service_name => 'Prod_App',
      port => 80,
      comments => 'Creating the server'
    }  

# This resource type connects the WAF to the Barracuda Cloud Control

    cudawaf_cloudcontrol { 'WAFCloudControlSettings':
      ensure         => present,
      connect_mode   => 'cloud',
      state          => 'connected',
      username       => 'customer_account@example.com',
      password       => 'xxxxxxxx'
    }
}

