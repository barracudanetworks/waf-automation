# site.pp ##

## Active Configurations ##

#This manifest is used to create a Barracuda WAF EC2 instance in AWS. Parameters such as Region, VPC, Subnet, Security group are all picked up from the hieradata/common.yaml file. So please make sure to keep common.yaml updated.
class aws {
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
ec2_instance { 'lampinstancebyPUPPET5':
  ensure            => running,
  region            => hiera('region'),
  availability_zone => hiera('svr_availability_zone'),
  image_id          => hiera('lamp_image'),
  instance_type     => 't2.micro',
  monitoring        => true,
  subnet            => hiera('websvr_subnet'),
  key_name          => hiera('waf_keypair'),
  security_groups   => ['server-sec-group'],
  user_data         => template("aws/lamp.sh.erb"),
  tags              => {
    tag_name => 'lampinstancebyPUPPET5',
  },
}

}
