# azureroles
Calls the manifests in the other modules. Refer to the manifests folder for details.

Manifest:

class azureroles {
include azureprofiles::azure_rg
include azureprofiles::wafcreate
include azureprofiles::lamp
include azurecudawafconfig::config
include vrsinazure::vrsconfig
}
~ 
