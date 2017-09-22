
# roles
Calls the other manifests in other modules. Refer to the manifests folder for details.

Manifest:

class roles {
        include profiles::base
        include profiles::wafsecgroup
        include profiles::serversecgroup
        include profiles::ec2create
        include awscudawafconfig::config
        include vrsinaws::vrsconfig
}
