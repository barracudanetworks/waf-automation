class profiles::elbcreate {
elb_loadbalancer { 'cuda-loadbalancer':
  ensure                  => present,
  region                  => 'us-west-2',
  availability_zones      => ['us-west-2a', 'us-west-2b'],
  #instances               => ['name-of-instance', 'another-instance'],
  #security_groups         => ['name-of-security-group'],
  listeners               => [
    {
      protocol              => 'HTTP',
      load_balancer_port    => 80,
      instance_protocol     => 'HTTP',
      instance_port         => 80,
    },
  ],
  tags                    => {
    tag_name              => 'Puppet_ELB',
  },
}
}
