require 'puppet/parameter/boolean'

require_relative '../../puppet_x/puppetlabs/azure/property/read_only'
require_relative '../../puppet_x/puppetlabs/azure/property/positive_integer'
require_relative '../../puppet_x/puppetlabs/azure/property/string'

Puppet::Type.newtype(:azure_storage_account) do
  @doc = 'Type representing a storage account in Microsoft Azure.'

  ensurable

  validate do
    required_properties = [
      :location,
      :resource_group,
    ]
    required_properties.each do |property|
      # We check for both places so as to cover the puppet resource path as well
      if self[:ensure] == :present and self[property].nil? and self.provider.send(property) == :absent
        fail "You must provide a #{property}"
      end
    end
  end

  newparam(:name, namevar: true, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'Name of the storage account.'
    validate do |value|
      super value
      fail 'the name must not be empty' if value.empty?
      fail("The name must be between 3 and 24 characters in length") if value.size > 24 or value.size < 3
    end
    def insync?(is)
      is.casecmp(should).zero?
    end
  end

  newproperty(:resource_group, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The name of the associated resource group'
    validate do |value|
      super value
      fail 'the resource group must not be empty' if value.empty?
    end
    def insync?(is)
      is.casecmp(should).zero?
    end
  end

  newproperty(:account_type, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The name of the storage account performance & replication SKU (account type)'
    newvalues('Standard_LRS', 'Standard_ZRS', 'Standard_GRS', 'Standard_RAGRS', 'Premium_LRS')
    defaultto 'Standard_GRS'
  end

  newproperty(:account_kind, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The kind of storage account'
    newvalues('Storage', 'BlobStorage')
    defaultto 'Storage'
  end

  newproperty(:location, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The location where the storage account will be created.'
    validate do |value|
      super value
      fail 'the location must not be empty' if value.empty?
    end
  end

  autorequire(:azure_resource_group) do
    self[:resource_group]
  end
end
