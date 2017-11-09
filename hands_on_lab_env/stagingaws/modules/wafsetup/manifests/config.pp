class WAFSetUp::config {

file {'eula_accept.rb':
  ensure => present,
  path   => '/home/ubuntu/eula_accept.rb',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/awscudawafconfig/eula_accept',
}

Exec {'ruby':
  command => '/usr/bin/ruby /home/ubuntu/eula_accept.rb >> /home/ubuntu/configresults.txt',
}

# Ensures that the file is created before running the command
File['eula_accept.rb'] -> Exec['ruby']
}
