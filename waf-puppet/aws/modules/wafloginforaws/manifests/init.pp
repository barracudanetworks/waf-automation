# Class: wafloginforaws
# ===========================
#
# Full description of class wafloginforaws here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'wafloginforaws':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class wafloginforaws {
file {'waflogintoken.rb':
  ensure => present,
  path   => '/home/vagrant/waflogintoken.rb',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  source => 'puppet:///modules/wafloginforaws/waflogintoken.rb',
}

Exec {'ruby':
  command => '/usr/bin/ruby /home/vagrant/waflogintoken.rb',
}

# Ensures that the file is created before running the command
File['waflogintoken.rb'] -> Exec['ruby']
}

}
