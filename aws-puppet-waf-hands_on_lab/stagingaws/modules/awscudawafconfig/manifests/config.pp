class awscudawafconfig::config {



file {'config_full_new.rb':
  ensure => present,
  path   => '/home/ubuntu/awswafconfig.rb',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/awscudawafconfig/config_full_new.rb',
}

Exec {'ruby':
  command => '/usr/bin/ruby /home/ubuntu/awswafconfig.rb >> /home/ubuntu/configresults.txt',
}

# Ensures that the file is created before running the command
File['config_full_new.rb'] -> Exec['ruby']
}
