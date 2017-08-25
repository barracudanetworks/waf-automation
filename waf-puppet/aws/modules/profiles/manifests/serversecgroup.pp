class profiles::serversecgroup {
ec2_securitygroup { 'server-sec-group':
  ensure      => present,
  region      => 'us-west-2',
  vpc	      => 'Ara-VPCNet',  
  description => 'a description of the group',
  ingress     => [{
    protocol  => 'tcp',
    port      => 80,
    cidr      => '0.0.0.0/0',
  },{
    protocol  => 'tcp',
    port      => 443,
    cidr      => '0.0.0.0/0',
},
    {
    protocol  => 'tcp',
    port      => 8000,
    cidr      => '0.0.0.0/0'}],
  tags        => {
    tag_name  => 'value',
  },
}
}
