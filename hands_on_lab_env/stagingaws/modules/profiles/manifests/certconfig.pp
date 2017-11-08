#This manifest uploads a signed certificate 
class profile::certconfig {
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
}
