require 'puppet/util/feature'

Puppet.features.add(:azure_classic, libs: [
  'azure',
])
