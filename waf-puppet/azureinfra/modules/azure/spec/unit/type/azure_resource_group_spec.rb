require 'spec_helper'

describe 'azure_resource_group', :type => :type do
  let(:type_class) { Puppet::Type.type(:azure_resource_group) }

  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :location,
    ]
  end

  let :default_config do
    {
      name: 'testrg',
      location: 'eastus',
    }
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
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  context 'with a minimal set of properties' do
    let :config do
      default_config
    end

    let :resource_group do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { resource_group }.to_not raise_error
    end

    context "when missing the location property" do
      it "should fail with ensure => present" do
        config.delete(:location)
        config[:ensure] = :present
        expect { resource_group }.to raise_error(Puppet::ResourceError, /You must provide a location/)
      end

      it "should not fail with ensure => absent" do
        config.delete(:location)
        config[:ensure] = :absent
        expect { resource_group }.to_not raise_error
      end
    end

    context 'with a blank location' do
      let :config do
        result = default_config
        result[:location] = ''
        result
      end

      it 'should be invalid' do
        expect { type_class.new(config) }.to raise_error(Puppet::ResourceError, /the location must not be empty/)
      end
    end


    it "should default ensure to present" do
      expect(resource_group[:ensure]).to eq(:present)
    end
  end

  context 'various invalidate names' do
    context 'with a name longer than 80 characters' do
      let :config do
        result = default_config
        result[:name] = SecureRandom.hex(41)
        result
      end

      it 'fails' do
        expect { type_class.new(config) }.to raise_error(Puppet::ResourceError, /The name must be less than 80 characters in length/)
      end
    end
    context 'with a name ending with a period' do
      let :config do
        result = default_config
        result[:name] = 'something.with.dots.'
        result
      end

      it 'fails' do
        expect { type_class.new(config) }.to raise_error(Puppet::ResourceError, /The name must not end in a period/)
      end
    end
  end
end
