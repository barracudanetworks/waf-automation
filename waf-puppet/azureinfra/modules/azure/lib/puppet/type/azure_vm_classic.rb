require 'puppet/parameter/boolean'

require_relative '../../puppet_x/puppetlabs/azure/property/read_only'
require_relative '../../puppet_x/puppetlabs/azure/property/positive_integer'
require_relative '../../puppet_x/puppetlabs/azure/property/string'

# azure_vm_classic { 'sample':
#   image            => 'b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_2-LTS-amd64-server-20150706-en-us-30GB',
#   location         => 'East US'
#   user             => 'azureuser',
#   password         => 'SpecPass123!@#$%',
#   storage_account  => 'storagesuse',
#   cloud_service    => 'cloud_service_name',
#   deployment       =>'vm_name',
#   private_key_file => './private_key.key', # required for ssh
#   size             => 'Small',
#   affinity_group   => 'affinity1',
#   virtual_network  => 'xplattestvnet',
#   subnet           => 'subnet1',
#   availability_set => 'availabiltyset1',
#   reserved_ip      => 'reservedipname'
#   endpoints        => [{
#     name        => 'ep-1',
#     public_port => 996,
#     local_port  => 998,
#     protocol    => 'TCP',
#   },{
#     name               => 'ep-2',
#     public_port        => 997,
#     local_port         => 997,
#     protocol           => 'TCP',
#     load_balancer_name => 'lb-ep2',
#     load_balancer      => { protocol => 'http', path => 'hello' },
#   }],
#   data_disk_size_gb    => '100',
#   purge_disk_on_delete => false,
# }

Puppet::Type.newtype(:azure_vm_classic) do
  @doc = 'Type representing a virtual machine in Microsoft Azure.'

  validate do
    if self[:password] and self[:private_key_file]
      fail 'You can only provide either a password or a private_key_file for an Azure VM'
    end
    if self[:subnet] and !self[:virtual_network]
      fail 'When specifying a subnet you must also specify a virtual network'
    end
    if self[:virtual_network] and self[:affinity_group]
      fail 'You can only provide either a virtual_network or an affinity_group for an Azure VM'
    end
    required_properties = [
      :location,
    ]
    required_properties.each do |property|
      # We check for both places so as to cover the puppet resource path as well
      if self[property].nil? and self.provider.send(property) == :absent
        fail "You must provide a #{property}"
      end
    end
  end

  newproperty(:ensure) do
    defaultto :present
    newvalue(:present) do
      provider.create unless provider.exists?
    end
    newvalue(:absent) do
      provider.destroy if provider.exists?
    end
    newvalue(:running) do
      if provider.exists?
        provider.start unless provider.running?
      else
        provider.create
      end
    end
    newvalue(:stopped) do
      if provider.exists?
        provider.stop unless provider.stopped?
      else
        provider.create
        provider.stop
      end
    end
    def change_to_s(current, desired)
      current = :running if current == :present
      desired = current if desired == :present and current != :absent
      current == desired ? current : "changed #{current} to #{desired}"
    end
    def insync?(is)
      is.to_s == should.to_s or
        (is.to_s == 'running' and should.to_s == 'present') or
        (is.to_s == 'stopped' and should.to_s == 'present')
    end
  end

  newparam(:name, namevar: true, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'Name of the virtual machine.'
  end

  newproperty(:image, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'Name of the image to use to create the virtual machine.'
    validate do |value|
      super value
      fail("the image name must not be empty") if value.empty?
    end
  end

  newparam(:user, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'User name for the virtual machine. This value is only used when creating the VM initially.'
  end

  newparam(:password, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The password for the virtual machine. This value is only used when creating the VM initially.'
  end

  newparam(:private_key_file, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'Path to the private key file. This value is only used when creating the VM initially.'
  end

  newproperty(:location, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The location where the virtual machine will be created.'
    validate do |value|
      super value
      fail 'the location must not be empty' if value.empty?
    end
  end

  newparam(:storage_account, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The storage account to create for the virtual machine.'
  end

  newproperty(:cloud_service, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The name of the associated cloud service.'
  end

  newproperty(:deployment, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The name for the deployment.'
  end

  newproperty(:size, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The size of the virtual machine instance.'
  end

  newparam(:affinity_group, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The affinity group to be used for the cloud service and the storage account. Must already exist in your account.'
  end

  newproperty(:virtual_network, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The virtual network to which the virtual machine should be connected.'
  end

  newproperty(:subnet, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The subnet to which the virtual machine should be associated.'
  end

  newproperty(:availability_set, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The availability set for the virtual machine.'
  end

  newparam(:reserved_ip, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'The name of the reserved IP to associate with the virtual machine.'
  end

  newproperty(:data_disk_size_gb, :parent => PuppetX::PuppetLabs::Azure::Property::PositiveInteger) do
    desc 'The size of the data disk for this virtual machine, specified in gigabytes.'
  end

  newparam(:purge_disk_on_delete, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether or not the attached data disk should be deleted when the VM is deleted.'
    defaultto false
  end

  newparam(:custom_data, :parent => PuppetX::PuppetLabs::Azure::Property::String) do
    desc 'A script to be executed on launch by Cloud-Init. Linux guests only.'
  end

  # Could also be represented by a separate type. Please provide feedback if you need additional flexibility here.
  newproperty(:endpoints, :array_matching => :all) do
    desc 'A list of endpoints which should be associated with the virtual machine.'
    validate do |value|
      fail "endpoints should be an Array of Hashes, but contains a #{value.class}" unless value.is_a? Hash
      stringified_value = Hash.new
      value.each { |k,v| stringified_value[k.to_s] = v }
      required = [ 'name', 'public_port', 'local_port', 'protocol' ]
      missing = required - stringified_value.keys.map(&:to_s)
      unless missing.empty?
        fail "an endpoint is missing the following keys: #{missing.join(',')}"
      end
      [ 'protocol', 'load_balancer_name' ].each do |key|
        if stringified_value.keys.include? key
          fail "#{key} for endpoints should be a String" unless stringified_value[key].is_a? String
        end
      end
      [ 'public_port', 'local_port' ].each do |key|
        if stringified_value.keys.include? key
          fail "#{key} for endpoints should be an Integer" unless stringified_value[key].to_i.to_s == stringified_value[key].to_s
        end
      end
      [ 'direct_server_return' ].each do |key|
        if stringified_value.keys.include? key
          fail "#{key} for endpoints should be a Boolean, not #{stringified_value[key].inspect}" unless [ 'true', 'false' ].include?(stringified_value[key].to_s)
        end
      end
      if stringified_value.keys.include? 'load_balancer'
        fail 'load_balancer for endpoints should be a Hash' unless stringified_value['load_balancer'].is_a? Hash
        fail 'having a load_balancer requires a load_balancer_name' unless stringified_value.keys.include? 'load_balancer_name'
      end
    end

    munge do |value|
      value = value.inject({}) { |memo,(k,v)| memo[k.to_sym] = v; memo }
      value[:protocol] = value[:protocol].downcase if value[:protocol].respond_to? :downcase
      value[:direct_server_return] = case value[:direct_server_return]
                                     when true, "true"
                                       "true"
                                     else
                                       "false"
                                     end
      value
    end

    def compare_values(keys, a, b)
      keys.all? { |k| a[k].to_s.casecmp(b[k].to_s).zero? }
    end

    def insync?(current)
      current.all? do |endpoint|
        should = @should.find { |s| s[:name].casecmp(endpoint[:name]).zero? }

        if should
          compare_values(should.keys + endpoint.keys - [:load_balancer, :name], endpoint, should)
        else
          false
        end
      end
    end

    def sync
      provider.update_endpoints(@should)
    end
  end

  [
    'os_type',
    'ipaddress',
    'hostname',
    'media_link',
  ].each do |property|
    newproperty(property, :parent => PuppetX::PuppetLabs::Azure::Property::ReadOnly) do
    end
  end
end
