
class azureroles {
include azureprofiles::azure_rg
include azureprofiles::wafcreate
include azureprofiles::lamp
include azurecudawafconfig::config
include vrsinazure::vrsconfig
}
