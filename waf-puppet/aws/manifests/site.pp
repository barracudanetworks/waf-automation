node 'awsnode' {
include roles
}

node 'puppet-master' {
include azure
}

node 'awsserver' {
include roles::server
}

node 'awswaf' {
include roles::waf
}

