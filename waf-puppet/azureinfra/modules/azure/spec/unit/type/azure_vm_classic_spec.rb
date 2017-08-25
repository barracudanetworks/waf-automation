require 'spec_helper'

describe 'azure_vm_classic', :type => :type do
  let(:type_class) { Puppet::Type.type(:azure_vm_classic) }

  let :params do
    [
      :name,
      :user,
      :password,
      :private_key_file,
      :purge_disk_on_delete,
      :custom_data,
      :storage_account,
      :reserved_ip,
      :affinity_group,
    ]
  end

  let :properties do
    [
      :ensure,
      :image,
      :location,
      :cloud_service,
      :deployment,
      :size,
      :virtual_network,
      :subnet,
      :availability_set,
      :data_disk_size_gb,
      :endpoints,
    ]
  end

  let :read_only_properties do
    [
      :os_type,
      :ipaddress,
      :hostname,
      :media_link,
    ]
  end

  it 'should have expected properties' do
    expect(type_class.properties.map(&:name)).to include(*(properties + read_only_properties))
  end

  it 'should have expected parameters' do
    expect(type_class.parameters).to include(*params)
  end

  it 'should not have unexpected properties' do
    expect(properties + read_only_properties).to include(*type_class.properties.map(&:name))
  end

  it 'should not have unexpected parameters' do
    expect(params + [:provider]).to include(*type_class.parameters)
  end

  it 'should require a name' do
    expect do
      type_class.new({})
    end.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  [
    'name',
    'image',
    'user',
    'password',
    'private_key_file',
    'location',
    'storage_account',
    'cloud_service',
    'deployment',
    'size',
    'affinity_group',
    'virtual_network',
    'subnet',
    'availability_set',
    'reserved_ip',
    'custom_data',
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  [
    'data_disk_size_gb',
  ].each do |property|
    it "should require #{property} to be a number" do
      expect(type_class).to require_integer_for(property)
    end

    it "should require #{property} to be greater than 0" do
      expect do
        config = {name: 'sample'}
        config[property] = 0
        type_class.new(config)
      end.to raise_error(Puppet::Error, /#{property} should be greater than 0/)
    end
  end

  include_examples "array properties", [
    :endpoints,
  ]

  include_examples "boolean properties", [
    :purge_disk_on_delete,
  ]

  [
    :os_type,
    :ipaddress,
    :hostname,
    :media_link,
  ].each do |property|
    it "should require #{property} to be read only" do
      expect(type_class).to be_read_only(property)
    end
  end

  it 'should default ensure to present' do
    machine = type_class.new(
      name: 'sample',
      location: 'West US',
    )
    expect(machine[:ensure]).to eq(:present)
  end

  context 'with a minimal set of properties' do
    let :config do
      {
        ensure: :present,
        name: 'image-test',
        location: 'West US',
        image: 'image-name',
        user: 'admin',
        private_key_file: '/not/a/real/private.key',
      }
    end

    let :machine do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { machine }.not_to raise_error
    end

    it 'should alias running to present for ensure values' do
      expect(machine.property(:ensure).insync?(:running)).to be true
    end

    it 'should default purge_disk_on_delete to false' do
      expect(machine[:purge_disk_on_delete]).to be_falsey
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
  end

  context 'with ensure set to stopped' do
    let :config do
      {
        ensure: :stopped,
        name: 'image-test',
        location: 'West US',
      }
    end

    it 'should acknowledge stopped machines to be present' do
      expect(type_class.new(config).property(:ensure).insync?(:stopped)).to be true
    end
  end

  context 'with a password and a private key file' do
    let :config do
      {
        ensure: :present,
        name: 'image-test',
        location: 'West US',
        password: 'no-a-real-password',
        private_key_file: '/not/a/real/private.key',
      }
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /You can only provide either a password or a private_key_file for an Azure VM/)
    end
  end

  context 'with a virtual_network and an affinity group' do
    let :config do
      {
        ensure: :present,
        name: 'image-test',
        location: 'West US',
        affinity_group: 'real-affinity-set',
        virtual_network: 'real-network',
      }
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /You can only provide either a virtual_network or an affinity_group for an Azure VM/)
    end
  end


  context 'with a image specified' do
    let :config do
      {
        ensure: :present,
        name: 'image-test',
        location: 'West US',
        image: 'image-name',
      }
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
      {
        ensure: :present,
        name: 'disk-test',
        location: 'West US',
      }
    end

    it 'should be valid' do
      expect { type_class.new(config) }.to_not raise_error
    end
  end

  context 'with a subnet but without a virtual network' do
    let :config do
      {
        ensure: :present,
        name: 'disk-test',
        location: 'West US',
        subnet: 'subnet-name',
      }
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /When specifying a subnet you must also specify a virtual network/)
    end
  end

  context 'with a subnet and a virtual network' do
    let :config do
      {
        ensure: :present,
        name: 'disk-test',
        location: 'West US',
        subnet: 'subnet-name',
        virtual_network: 'network-name',
      }
    end

    it 'should be valid' do
      expect { type_class.new(config) }.to_not raise_error
    end
  end

  context 'with a blank location' do
    let :config do
      {
        ensure: :present,
        name: 'disk-test',
        location: '',
      }
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /the location must not be empty/)
    end
  end

  context 'with no location' do
    let :config do
      {
        ensure: :present,
        name: 'disk-test',
      }
    end

    it 'should be invalid' do
      expect { type_class.new(config) }.to raise_error(Puppet::Error, /You must provide a location/)
    end
  end

  context 'with an endpoint specified' do
    let :config do
      {
        ensure: :present,
        name: 'endpoint-test',
        location: 'West US',
        endpoints: {
          name: 'ep-1',
          public_port: 996,
          local_port: 998,
          protocol: 'TCP',
          direct_server_return: true,
        },
      }
    end

    it 'should be valid' do
      expect { type_class.new(config) }.to_not raise_error
    end

    [ true, false, "true", "false" ].each do |value|
      context "with direct_server_return set to #{value.inspect}" do
        let :config do
          {
            ensure: :present,
            name: 'endpoint-test',
            location: 'West US',
            endpoints: {
              name: 'ep-1',
              public_port: 996,
              local_port: 998,
              protocol: 'TCP',
              direct_server_return: value,
            },
          }
        end

        it 'should have stringified direct_server_return correctly' do
          instance = type_class.new(config)
          expect(instance[:endpoints].first[:direct_server_return]).to eq value.to_s
        end
      end
    end

    context 'with no direct_server_return set' do
      let :config do
        {
          ensure: :present,
          name: 'endpoint-test',
          location: 'West US',
          endpoints: {
            name: 'ep-1',
            public_port: 996,
            local_port: 998,
            protocol: 'TCP',
          },
        }
      end

      it 'should have stringified direct_server_return correctly' do
        instance = type_class.new(config)
        expect(instance[:endpoints].first[:direct_server_return]).to eq 'false'
      end
    end

    [:name, :public_port, :local_port, :protocol].each do |key|
      it "should require endpoint to have a #{key} key" do
        expect do
          config[:endpoints].delete(key)
          type_class.new(config)
        end.to raise_error(Puppet::Error, /an endpoint is missing the following keys: #{key}/)
      end
    end

    [:local_port, :public_port].each do |port|
      it "should require endpoint #{port} to be an integer" do
        expect do
          config[:endpoints][port] = 'invalid'
          type_class.new(config)
        end.to raise_error(Puppet::Error, /#{port} for endpoints should be an Integer/)
      end
    end

    context 'with an unnamed load balancer specified' do
      let :config do
        {
          ensure: :present,
          name: 'endpoint-test',
          location: 'West US',
          endpoints: {
            name: 'ep-1',
            public_port: 996,
            local_port: 998,
            protocol: 'TCP',
            load_balancer: {
              port: 60,
              protocol: 'tcp',
            }
          },
        }
      end

      it 'should be invalid' do
        expect { type_class.new(config) }.to raise_error(Puppet::Error, /having a load_balancer requires a load_balancer_name/)
      end
    end

    context 'with a named load balancer specified' do
      let :config do
        {
          ensure: :present,
          name: 'endpoint-test',
          location: 'West US',
          endpoints: {
            name: 'ep-1',
            public_port: 996,
            local_port: 998,
            protocol: 'TCP',
            load_balancer_name: 'lb-1',
            load_balancer: {
              port: 60,
              protocol: 'tcp',
            }
          },
        }
      end

      it 'should be valid' do
        expect { type_class.new(config) }.to_not raise_error
      end
    end
  end
end
