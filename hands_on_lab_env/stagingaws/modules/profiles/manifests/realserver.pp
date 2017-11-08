##init.pp##
class barracudawaf {
#wafcertificates{ 'WAFUPLOADTRUSTEDCER-1':
#  ensure => present,
#  cer_name => 'wafuploadtrustedcert1',
#  name => 'trustedcert1',
#  trusted_certificate => '/home/wafcertificates/cer.pem', 
#  upload => 'trusted'
#}
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

}
