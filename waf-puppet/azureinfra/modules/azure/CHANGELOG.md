## Supported Version 1.1.0
### Summary
This release adds several more useful resource types for managing Azure resource groups, storage accounts, and resource templates. It also expands the capabilities of the `azure_vm` type by adding support for managing extensions, data disks, custom data, and deploying from marketplace images.

### Added
- `azure_resource_group` type for resource group management
- `azure_storage_account` type for storage account management
- `azure_resource_template` type for template management
- `extensions` parameter to `azure_vm` for extension configuration
- `plan` parameter to `azure_vm` for Azure Marketplace images
- `data_disks` parameter to `azure_vm` for data disk configuration
- `custom_data` parameter to `azure_vm` for custom data configuration

### Fixed
- Updated to 1.1.2 version of hocon gem (includes windows fixes)
- No longer requires azure.conf classic credentials for only ARM or vice versa
- Better printing of error messages from azure's API
- Allow `azure_vm::public_ip_allocation_method => 'None'` to work


## Supported Version 1.0.3
### Summary
This release updates the module for the 0.3.0 version of the azure gems and
fixes a bug for Azure::Core

### Fixed
- Update to 0.3.0 version of azure\_mgmt\* gems
- Fix Azure::Core require
- Fix paging of REST when lots of VMs
- Fix puppet resource failing validation
- Fix docs mentioning incorrect quoting in azure.conf
- Fix bundlered listen gem failing on older rubies
- Fix lint warnings in examples/\*.pp
- Add Debian 8 to metadata
- Fix domain to be spec-specific

## Supported Version 1.0.2

This release includes:
* (CLOUD-488) Windows agent support for the Azure module testing.
* Several test improvements and fixes.
* Fixes validation for name length.
* Updates module for Hocon 1.0.0 compatibility.
* Improves error reporting.
* Adds apt-get update before install for custom_data param.

## 2015-12-08 - Supported Version 1.0.1

This release includes:

* Updates to the metadata to identify supported Windows platforms
* Improvements to the documentation around Windows support
* Fixes to URLs pointing at the previous Git repository

## 2015-12-08 - Supported Release 1.0.0

The first public release of the Azure module provides support for
managing VMs in both the Service Management (Classic) and new Resource
Management APIs in Azure.

