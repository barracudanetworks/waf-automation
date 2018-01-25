class vrsinaws::vrsconfig {



file {'configure_vrs.rb':
  ensure => present,
  path   => '/home/vagrant/vrsconfig.rb',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/vrsinaws/configure_vrs.rb',
}

Exec {'ruby-for-vrs':
  command => '/usr/bin/ruby /home/vagrant/vrsconfig.rb >> /home/vagrant/vrsconfigresults.txt',
}

# Ensures that the file is created before running the command
File['configure_vrs.rb'] -> Exec['ruby']
}
