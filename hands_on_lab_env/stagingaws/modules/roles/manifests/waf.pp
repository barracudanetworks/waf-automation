class roles::waf {
	include profiles::wafsecgroup
	include profiles::wafcreate
	include WAFSetUp::config
	include profiles::certconfig
	include profiles::wafconfig
	include profiles::realserver
}

