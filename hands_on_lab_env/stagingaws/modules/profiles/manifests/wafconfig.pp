#This manifest will create the service on the WAF
class profiles::wafconfig {
$vip = $waf_private_ip

wafservices  { 'WAFSVC-1':
  ensure	=> present,
  name          => 'WAFSERVICE',
  type		=> 'http',
  mask		=> '255.255.255.255',
  ip_address	=> '$vip',
  port		=> '80',
  group		=> 'default',
  vsite		=> 'default',
  status		=> 'On',
  address_version	=> 'ipv4',
  enable_access_logs => 'Yes',
  svcname => 'ProdService',
	}
}
