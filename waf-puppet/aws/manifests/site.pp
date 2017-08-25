node 'awsnode' {
include roles
}

node 'puppet-master' {
include azure
}

node 'win-mgnd6ol98gp' {
include azure
}

