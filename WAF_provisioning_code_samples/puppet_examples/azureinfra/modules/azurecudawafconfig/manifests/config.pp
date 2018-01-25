class azurecudawafconfig::config {


file {'config_full_azure.rb':
  ensure => present,
  path   => '/home/vagrant/configazure.rb',
  owner  => 'vagrant',
  group  => 'vagrant',
  mode   => '0644',
  source => 'puppet:///modules/azurecudawafconfig/config_full_azure.rb',
}

Exec {'ruby':
  command => '/usr/bin/ruby /home/vagrant/configazure.rb',
}

# Ensures that the file is created before running the command
File['config_full_azure.rb'] -> Exec['ruby']
}
