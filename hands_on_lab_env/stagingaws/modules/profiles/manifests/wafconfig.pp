#This manifest will create the service on the WAF
class profiles::wafconfig {
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
