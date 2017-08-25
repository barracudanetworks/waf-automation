class vrsinazure::vrsconfig {


file {'vrsconfig.rb':
  ensure => present,
  path   => '/home/vagrant/vrsconfig.rb',
  owner  => 'vagrant',
  group  => 'vagrant',
  mode   => '0644',
  source => 'puppet:///modules/vrsinazure/vrsconfig.rb',
}

Exec {'vrsexec':
  command => '/usr/bin/ruby /home/vagrant/vrsconfig.rb',
}

# Ensures that the file is created before running the command
File['vrsconfig.rb'] -> Exec['ruby']
}
