require 'puppet/util/feature'

Puppet.features.add(:azure, libs: [
  'azure_mgmt_compute',
  'azure_mgmt_network',
  'azure_mgmt_resources',
  'azure_mgmt_storage',
])
