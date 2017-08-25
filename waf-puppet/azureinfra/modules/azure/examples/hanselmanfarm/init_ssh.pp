# Deploy a three-node load-balanced webservice

# To allow per-machine SSH-ports, the configuration has to be split up a little bit.
# The first part here is the common definition for the load balanced web endpoint.
$web_load_balancer = {
    name               => 'weblb',
    public_port        => 80,
    local_port         => 80,
    protocol           => 'TCP',
    load_balancer_name => 'HttpTrafficIn',
    load_balancer      => {
      port     => 80,
      protocol => 'http',
      interval => 5,
      path     => '/test.php',
    },
  }

  $install_apache = 'sudo apt-get update && sudo apt-get install apache2 libapache2-mod-php5 php5 -y"
  $create_php = "sudo sh -c "echo \'<?php echo gethostbyname(trim(\"`hostname`\")); ?><?php phpinfo(); ?>\' > /var/www/html/test.php"'
# these defaults are used by all three machines
Azure_vm_classic {
  ensure        => present,
  image         => 'b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_3-LTS-amd64-server-20150908-en-us-30GB',
  location      => 'West US',
  user          => 'scott',
  password      => 'secretpw',
  # private_key_file => '/path/to/id_rsa',
  size          => 'Small',
  custom_data   => "${install_apache} && ${create_php}",
  cloud_service => 'hanselmanfarmcs', # change this
  availability_set => 'hanselmanfarmas'
}

# define the three machines with different ssh public ports, reusing the values from above
azure_vm_classic {
  'hanselmanfarm':
    endpoints        => [$web_load_balancer,
      {
        name        => 'ssh',
        local_port  => 22,
        public_port => 2201,
        protocol    => 'tcp',
      },
    ];
  'hanselmanfarm-2':
    endpoints        => [$web_load_balancer,
      {
        name        => 'ssh',
        local_port  => 22,
        public_port => 2202,
        protocol    => 'tcp',
      },
    ];
  'hanselmanfarm-3':
    endpoints        => [$web_load_balancer,
      {
        name        => 'ssh',
        local_port  => 22,
        public_port => 2203,
        protocol    => 'tcp',
      },
    ];
}
