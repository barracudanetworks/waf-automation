# This is the main manifest file in the environment. 
#A puppet agent node connecting to this environment will be rendered a catalog based on this manifest. 
#In this particular manifest, roles are assigned based on the node's hostname. 
#For example, the host with the hostname of 'awsserver', will be executing the server.pp manifest in the roles module. 
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

