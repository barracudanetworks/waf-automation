require 'puppet/parameter/boolean'

require_relative '../../puppet_x/puppetlabs/azure/property/read_only'
require_relative '../../puppet_x/puppetlabs/azure/property/positive_integer'
require_relative '../../puppet_x/puppetlabs/azure/property/string'

Puppet::Type.newtype(:azure_resource_group) do
  @doc = 'Type representing a resource group in Microsoft Azure.'

  ensurable

  validate do
    required_properties = [
      :location,
    ]
    required_properties.each do |property|
      # We check for both places so as to cover the puppet resource path as well
      if self[:ensure] == :present and self[property].nil? and self.provider.send(property) == :absent
        fail "You must provide a #{property}"
      end
    end
  end

  newparam(:name, namevar: true, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'Name of the resource group.'
    validate do |value|
      super value
      # "It must be no longer than 80 characters long. It can contain only
      # alphanumeric characters, dash, underscore, opening parenthesis, closing
      # parenthesis, and period. The name cannot end with a period."
      fail("The name must be less than 80 characters in length") if value.size > 80
      fail("The name must not end in a period") if value[-1] == "."
      fail("The name can contain only alphanumeric characters, dash, underscore, open/close parentheses, and period.") unless value =~ %r{^[\w\-\(\)\.]+$}
    end
    def insync?(is)
      is.casecmp(should).zero?
    end
  end

  newproperty(:location, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The location where the resource group will be created.'
    validate do |value|
      super value
      fail 'the location must not be empty' if value.empty?
    end
  end
end
