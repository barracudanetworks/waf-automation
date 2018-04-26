class profiles::servercreate {
ec2_instance { 'lampinstancebyPUPPET6':
  ensure            => running,
  region            => hiera('region'),
  availability_zone => hiera('svr_availability_zone'),
  image_id          => hiera('lamp_image'),
  instance_type     => 't2.micro',
  monitoring        => true,
  subnet            => hiera('websvr_subnet'),
  key_name          => hiera('waf_keypair'),
  security_groups   => ['server-sec-group'],
  user_data         => template("profiles/lamp.sh.erb"),
  tags              => {
    tag_name => 'lampinstancebyPUPPET6',
  },
}

}
