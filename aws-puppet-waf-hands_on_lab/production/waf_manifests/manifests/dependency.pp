class cudawaf::dependency {
 # this installs the typhoeus gem on the agent system
 package { 'typhoeus' :
    ensure => present,
    provider => 'puppet_gem',
  }
  # this installs the rest-client v1.8.0 gem on the agent system
 package { 'rest-client' :
    ensure => '1.8.0',
    provider => 'puppet_gem',
  }
}
