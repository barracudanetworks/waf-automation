class cudawaf::dependency {
 package { 'typhoeus' :
    ensure => present,
    provider => 'puppet_gem',
  }
 package { 'rest-client' :
    ensure => '1.8.0',
    provider => 'puppet_gem',
  }
}
