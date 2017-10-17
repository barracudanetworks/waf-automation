class awscudawafconfig::config {



file {'config_full_new.rb':
  ensure => present,
  path   => '/home/vagrant/awswafconfig.rb',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/awscudawafconfig/config_full_new.rb',
}

Exec {'ruby':
  command => '/usr/bin/ruby /home/vagrant/awswafconfig.rb >> /home/vagrant/configresults.txt',
}

# Ensures that the file is created before running the command
File['config_full_new.rb'] -> Exec['ruby']
}
