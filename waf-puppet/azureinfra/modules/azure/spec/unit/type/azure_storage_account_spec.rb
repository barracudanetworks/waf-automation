require 'spec_helper'

describe 'azure_storage_account', :type => :type do
  let(:type_class) { Puppet::Type.type(:azure_storage_account) }

  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :location,
      :account_type,
      :account_kind,
      :resource_group,
    ]
  end

  let :default_config do
    {
      name: 'testsa',
      location: 'eastus',
      resource_group: 'testresourcegrp',
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
    'account_type',
    'account_kind',
    'resource_group',
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  context 'with a minimal set of properties' do
    let :config do
      default_config
    end

    let :storage_account do
      type_class.new(config)
    end

    it 'should be valid' do
      expect { storage_account }.to_not raise_error
    end

    [
      :location,
      :resource_group,
    ].each do |key|
      context "when missing the #{key} property" do
        it "should fail with ensure => present" do
          config.delete(key)
          config[:ensure] = :present
          p config
          expect { storage_account }.to raise_error(Puppet::Error, /You must provide a #{key}/)
        end
      end
      it "should not fail with ensure => absent" do
        config.delete(key)
        config[:ensure] = :absent
        expect { storage_account }.to_not raise_error
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
      expect(storage_account[:ensure]).to eq(:present)
    end
  end
end
