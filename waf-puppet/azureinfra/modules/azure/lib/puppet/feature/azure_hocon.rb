require 'puppet/util/feature'

Puppet.features.add(:azure_hocon, libs: ['hocon', 'hocon/config_factory', 'hocon/config_error'])
