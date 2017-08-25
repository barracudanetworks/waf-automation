require 'spec_helper'

describe 'azure_vm', :type => :type do
  let(:type_class) { Puppet::Type.type(:azure_vm) }

  let :params do
    [
      :password,
      :name,
      :custom_data,
      :dns_domain_name,
      :dns_servers,
      :public_ip_address_name,
      :public_ip_allocation_method,
      :public_ip_address_name,
      :ip_configuration_name,
      :virtual_network_name,
      :virtual_network_address_space,
      :private_ip_allocation_method,
      :subnet_name,
      :subnet_address_prefix,
      :storage_account,
      :storage_account_type,
    ]
  end

  let :properties do
    [
      :ensure,
      :location,
      :image,
      :size,
      :user,
      :os_disk_name,
      :os_disk_caching,
      :os_disk_create_option,
      :resource_group,
      :os_disk_vhd_container_name,
      :os_disk_vhd_name,
      :network_interface_name,
      :extensions,
      :data_disks,
      :plan,
    ]
  end

  let :minimal_config do
    {
      name: 'testvm',
      location: 'eastus',
      image: 'canonical:ubuntuserver:14.04.2-LTS:latest',
      size: 'Standard_A0',
      user: 'specuser',
      password: 'Pa55wd!',
      resource_group: 'testresourcegrp',
    }
  end

  let :optional_config do
    {
      os_disk_name: 'testosdisk1',
      os_disk_caching: 'ReadWrite',
      os_disk_create_option: 'FromImage',
      os_disk_vhd_container_name: 'conttest1',
      os_disk_vhd_name: 'vhdtest1',
      dns_domain_name: 'mydomain01',
      dns_servers: '10.1.1.1 10.1.2.4',
      public_ip_allocation_method: 'Dynamic',
      public_ip_address_name: 'ip_name_test01pubip',
      virtual_network_name: 'vnettest01',
      virtual_network_address_space: '10.0.0.0/16',
      subnet_name: 'subnet111',
      subnet_address_prefix: '10.0.2.0/24',
      ip_configuration_name: 'ip_config_test01',
      private_ip_allocation_method: 'Dynamic',
      network_interface_name: 'nicspec01',
      storage_account: 'teststorageaccount',
      storage_account_type: 'Standard_GRS',
      extensions: {
        'CustomScriptForLinux' => {
          'auto_upgrade_minor_version' => false,
          'publisher'                  => 'Microsoft.OSTCExtensions',
          'type'                       => 'CustomScriptForLinux',
          'type_handler_version'       => '1.4',
          'settings'                   => {
            'commandToExecute' => 'sh script.sh',
            'fileUris'         => ['https://iaasv2tempstoreeastus.blob.core.windows.net/vmextensionstemporary-0003bf']
          },
        },
      },
    }
  end

  let :default_config do
     minimal_config.merge(optional_config)
  end

  it 'should have expected properties' do
    expect(type_class.properties.map(&:name)).to include(*properties)
  end

  it 'should have expected parameters' do
    expect(type_class.parameters).to include(*params)
  end

  it 'should not have unexpected properties' do
    expect(properties).to include(*type_class.properties.map(&:name))
  end

  it 'should not have unexpected parameters' do
    expect(params + [:provider]).to include(*type_class.parameters)
  end


  [
    'location',
    'image',
    'size',
    'custom_data',
    'resource_group',
    'storage_account',
    'storage_account_type',
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  context 'with a minimal set of properties' do
    let :config do
      minimal_config
    end

    let :machine do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { machine }.not_to raise_error
    end

    it 'should ignore case differences for image' do
      expect(machine.property(:image).insync?(minimal_config[:image].upcase)).to be true
    end

    it 'should alias running to present for ensure values' do
      expect(machine.property(:ensure).insync?(:running)).to be true
    end

    context 'when out of sync' do
      it 'should report actual state if desired state is present, as present is overloaded' do
        expect(machine.property(:ensure).change_to_s(:running, :present)).to eq(:running)
      end

      it 'if current and desired are the same then should report value' do
        expect(machine.property(:ensure).change_to_s(:stopped, :stopped)).to eq(:stopped)
      end

      it 'if current and desired are different should report change' do
        expect(machine.property(:ensure).change_to_s(:stopped, :running)).to eq('changed stopped to running')
      end
    end


    [
      :location,
    ].each do |key|
      context "when missing the #{key} property" do
        it "should fail" do
          config.delete(key)
          expect { machine }.to raise_error(Puppet::Error, /You must provide a #{key}/)
        end
      end
    end

    {
      :ensure => :present,
      :storage_account_type => 'Standard_GRS',
      :os_disk_caching => 'ReadWrite',
      :os_disk_create_option => 'FromImage',
      :os_disk_vhd_container_name => 'vhds',
      :dns_servers => '10.1.1.1 10.1.2.4',
      :public_ip_allocation_method => 'Dynamic',
      :virtual_network_address_space => '10.0.0.0/16',
      :subnet_name => 'default',
      :subnet_address_prefix => '10.0.2.0/24',
      :private_ip_allocation_method => 'Dynamic',
      :extensions => nil,
    }.each do |property, value|
      it "should default #{property} to #{value}" do
        expect(machine[property]).to eq(value)
      end
    end
  end

  context 'with ensure set to stopped' do
    let :config do
      default_config
    end

    it 'should acknowledge stopped machines to be present' do
      expect(type_class.new(config).property(:ensure).insync?(:stopped)).to be true
    end
  end


  context 'with a image specified' do
    let :config do
      default_config
    end

    it 'should be valid' do
      expect { type_class.new(config) }.to_not raise_error
    end

    it "should require image to have a value" do
      expect do
        config[:image] = ''
        type_class.new(config)
      end.to raise_error(Puppet::Error, /the image name must not be empty/)
    end
  end

  context 'with a location' do
    let :config do
      default_config
    end

    it 'should be valid' do
      expect { type_class.new(config) }.to_not raise_error
    end
  end

  context 'with a blank location' do
    let :config do
      result = default_config
      result[:location] = ''
      result
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /the location must not be empty/)
    end
  end

  context 'with a name greater than 64 characters' do
    let :config do
      result = default_config
      result[:name] = SecureRandom.hex(33)
      result
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /the name must be between 1 and 64 characters long/)
    end
  end

  context 'with a resource group greater than 64 characters' do
    let :config do
      result = default_config
      result[:resource_group] = SecureRandom.hex(33)
      result
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /the resource group must be less that 65 characters/)
    end
  end

  context 'with no location' do
    let :config do
      result = default_config
      result.delete(:location)
      result
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /You must provide a location/)
    end
  end

  context 'with a blank size' do
    let :config do
      result = default_config
      result[:size] = ''
      result
    end

    it 'should raise an error' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /the size must not be empty/)
    end
  end

  context 'with a blank password' do
    let :config do
      result = default_config
      result[:password] = ''
      result
    end

    it 'should raise an error' do
      expect { type_class.new(config) }.to raise_error(Puppet::ResourceError, /the password must not be empty/)
    end
  end
end
