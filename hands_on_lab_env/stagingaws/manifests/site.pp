
node 'appnode' {
include roles::server
}

node 'wafnode' {
include roles::waf
}

