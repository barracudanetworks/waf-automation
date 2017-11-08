##init.pp##
class barracudawaf {
wafservices  { 'WAFSVC-1':
  ensure	=> present,
  name          => 'WAFGETSERVICE',
  type		=> 'http',
  dps_enabled	=> 'no',
  mask		=> '255.255.255.255',
  ip_address	=> '3.3.3.3',
  port		=> '80',
  group		=> 'default',
  vsite		=> 'default',
  status		=> 'On',
  address_version	=> 'ipv4',
  comments	=> 'testing',
  app_id		=> '1',
  enable_access_logs => 'Yes',
  session_timeout	=> '60',
  svcname => 'bhanu',
  api_method => 'GET',
}

wafservices { 'WAFSVC-2':
  ensure        => present,  
  name          => 'WAFPOSTSERVICE',
  type          => 'http',
  dps_enabled   => 'no',
  mask          => '255.255.255.255',
  ip_address    => '2.2.2.2',
  port          => '80',
  group         => 'default',
  vsite         => 'default',
  status                => 'On',
  address_version       => 'ipv4',
  comments      => 'testing',
  app_id                => '1',
  enable_access_logs => 'Yes',
  session_timeout       => '60',
  svcname => 'demo_service_12',
  api_method => 'POST',
}

wafservices { 'WAFSVC-6':
  ensure        => present,
  name          => 'WAFPOSTSERVICE1',
  type          => 'http',
  dps_enabled   => 'no',
  mask          => '255.255.255.255',
  ip_address    => '8.8.8.8',
  port          => '80',
  group         => 'default',
  vsite         => 'default',
  status                => 'On',
  address_version       => 'ipv4',
  comments      => 'post call to create a service in waf',
  app_id                => '1',
  enable_access_logs => 'Yes',
  session_timeout       => '60',
  svcname => 'demo_service_13',
  api_method => 'POST',
}


wafservices { 'WAFSVC-3':
  ensure => present,
  name   => 'WAFPUTSERVICE',
  enable_access_logs=> 'Yes',
  address_version=> 'IPv4',
  vsite=> 'default',
  port => '80',
  group => 'default',
  type => 'HTTP',
  session_timeout => '60',
  ip_address =>  '8.8.8.8',
  svcname => 'demo_service_13',
  app_id => '1',
  mask => '255.255.255.255',
  comments =>'PUT call',
  status => 'Off',
  api_method => 'PUT',
}

wafservices { 'WAFSVC-4':
  ensure => present,
  name   => 'WAFDELETESERVICE',
  svcname => 'demo_service_12',
  api_method => 'DELETE',
}

wafservices { 'WAFSVC-5':
  ensure        => present,
  name          => 'WAFGETALLSERVICES',
  type          => 'http',
  mask          => '255.255.255.255',
  ip_address    => '3.3.3.3',
  port          => '80',
  group         => 'default',
  vsite         => 'default',
  status                => 'On',
  address_version       => 'ipv4',
  comments      => 'testing',
  app_id                => '1',
  enable_access_logs => 'Yes',
  session_timeout       => '60',
  svcname => 'demo_service_11',
  api_method => 'GETALLSERVICES',
}

}
