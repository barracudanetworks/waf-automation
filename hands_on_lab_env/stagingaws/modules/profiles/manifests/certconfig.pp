##init.pp##
class barracudawaf {
wafcertificates{ 'WAFCER-1':
  ensure => present,
  name  => 'WAFCERTIFICATESPOST1',
  allow_private_key_export =>'Yes',
  city   =>'Bangalore',
  common_name=> 'waf.test.local',
  country_code => 'IN',
  curve_type => 'secp256r1',
  key_size => '1024',
  key_type => 'rsa',
  cer_name => 'testCerticate3',
  organization_name => 'Barracuda Networks',
  organization_unit => 'Engineering',
  state => 'Karnataka',
}
wafcertificates{ 'WAFUPLOADTRUSTEDCER-1':
  ensure => present,
  cer_name => 'wafuploadtrustedcert3',
  name => 'trustedcert3',
  trusted_certificate => '/home/wafcertificates/cer.pem',
  upload => 'trusted'
}
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
wafcertificates{ 'WAFUPLOADTRUSTEDSERVERCER-1':
  ensure => present,
  cer_name => 'wafuploadtrustedservercert1',
  name => 'trustedservercert1',
  trusted_server_certificate => '/home/wafcertificates/cer.pem',
  upload => 'trusted_server'
}


}
