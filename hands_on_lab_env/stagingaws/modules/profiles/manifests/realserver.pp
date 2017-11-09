##This manifest creates the real server
class profile::realserver {
wafservers{ 'WAFSERVER-2':
  ensure => present,
  name => 'server2',
  require => Wafservices['WAFSVC-1'],
  identifier=> 'IP Address',
  address_version => 'IPv4',
  status => 'In Service',
  ip_address => '8.8.8.8',
  service_name => 'ProdService',
  hostname => 'TEST',
  port => '80',
  comments => 'Creating the server'
}

}
