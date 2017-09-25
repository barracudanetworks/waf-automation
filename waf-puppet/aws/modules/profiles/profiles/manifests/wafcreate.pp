class profiles::wafcreate {
ec2_instance { 'awswafinstancebyPUPPET5':
  ensure            => running,
  region            => hiera('region'),
  availability_zone => hiera('waf_availability_zone'),
  image_id          => hiera('waf_ami'),
  instance_type     => 'm3.medium',
  monitoring        => true,
  subnet	    => hiera('waf_subnet'),
  key_name          => hiera('waf_keypair'),
  security_groups   => ['cudawaf-sec-group'],
  tags              => {
    tag_name => 'awswafinstancebyPUPPET5',
  },
}

}
