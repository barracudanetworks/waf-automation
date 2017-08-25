require 'puppet/parameter/boolean'

require_relative '../../puppet_x/puppetlabs/azure/property/read_only'
require_relative '../../puppet_x/puppetlabs/azure/property/positive_integer'
require_relative '../../puppet_x/puppetlabs/azure/property/string'
require_relative '../../puppet_x/puppetlabs/azure/property/hash'

Puppet::Type.newtype(:azure_resource_template) do
  @doc = 'Type representing a resource template in Microsoft Azure.'

  ensurable

  validate do
    required_properties = [
      :resource_group,
    ]
    required_properties.each do |property|
      # We check for both places so as to cover the puppet resource path as well
      if self[:ensure] == :present and self[property].nil? and self.provider.send(property) == :absent
        fail "You must provide a #{property}"
      end
    end
    if self[:params] and self[:params_source]
      fail 'Cannot specify both a params and params_source'
    end
    if self[:source] and self[:content]
      fail 'Cannot specify both a source and content'
    end
  end

  newparam(:name, namevar: true, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'Name of the resource template.'
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

  newproperty(:source, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'URI of template file.'
    newvalues(%r{^https?://}) # and eventually puppet:// or files
  end

  newparam(:content, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    # TODO This could be made into a property, but the content returned by the
    # export_template method is not exactly the same as the user passed in and
    # would need filtering before idempotence is acheived.
    desc 'Contents of template'
    def insync?(is)
      is == JSON.parse(should)
    end
    # TODO This only shows additions to the is, not the should. It should
    # conditionally show either/or, depending on which ones have additions.
    #def is_to_s(is)
    #  "Template diff: #{is.to_a - JSON.parse(self.should).to_a}}"
    #end
    #def should_to_s(should)
    #  "<large output suppressed>"
    #end
  end

  newproperty(:params, :parent => PuppetX::PuppetLabs::Azure::Property::Hash) do
    desc 'Hash of the parameters required by the template. Required'
  end

  newproperty(:params_source, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'URI of template file.'
    newvalues(%r{^https?://}) # and eventually puppet:// or files
  end

  autorequire(:azure_resource_group) do
    self[:resource_group]
  end
end
