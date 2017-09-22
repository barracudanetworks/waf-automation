class roles {
	include profiles::base
	include profiles::wafsecgroup
	include profiles::serversecgroup
	include profiles::ec2create
	include awscudawafconfig::config
	include vrsinaws::vrsconfig
}

