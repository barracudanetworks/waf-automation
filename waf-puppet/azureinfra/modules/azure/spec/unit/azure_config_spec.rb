require 'spec_helper'
require 'puppet_x/puppetlabs/azure/config'
require 'hocon/config_factory'

def nil_environment_variables
  ENV.delete('AZURE_SUBSCRIPTION_ID')
  ENV.delete('AZURE_MANAGEMENT_CERTIFICATE')
end

def create_config_file(path, config)
  file_contents = %{
azure: {
  subscription_id: #{config[:subscription_id]}
  management_certificate: #{config[:management_certificate]}
}
  }
  File.open(path, 'w') { |f| f.write(file_contents) }
end

def create_incomplete_config_file(path, config)
  file_contents = %{
azure: {
  tenant_id: #{config[:tenant_id]}
}
  }
  File.open(path, 'w') { |f| f.write(file_contents) }
end


describe PuppetX::Puppetlabs::Azure::Config do
  let(:config_file_path) { File.join(Dir.pwd, '.puppet_azure.conf') }

  context 'with the relevant environment variables set' do
    let(:config) { PuppetX::Puppetlabs::Azure::Config.new }

    before(:all) do
      @config = {
        subscription_id: 'abc123',
        management_certificate: '/fake/path',
      }
      nil_environment_variables
      ENV['AZURE_SUBSCRIPTION_ID'] = @config[:subscription_id]
      ENV['AZURE_MANAGEMENT_CERTIFICATE'] = @config[:management_certificate]
    end

    it 'should allow for calling default_config_file more than once' do
      config.default_config_file
      expect { config.default_config_file }.not_to raise_error
    end

    it 'should return the subscription_id from an ENV variable' do
      expect(config.subscription_id).to eq(@config[:subscription_id])
    end

    it 'should return the management_certificate from an ENV variable' do
      expect(config.management_certificate).to eq(@config[:management_certificate])
    end

    it 'should set the default config file location to confdir' do
      expect(File.dirname(config.default_config_file)).to eq(Puppet[:confdir])
    end
  end

  context 'with no environment variables and a valid config file' do
    let(:config) { PuppetX::Puppetlabs::Azure::Config.new(config_file_path) }

    before(:all) do
      @config = {
        subscription_id: 'abc123',
        management_certificate: '/fake/path',
      }
      @path = File.join(Dir.pwd, '.puppet_azure.conf')
      create_config_file(@path, @config)
      nil_environment_variables
    end

    after(:all) do
      File.delete(@path)
    end

    it 'should return the subscription_id from the config file' do
      expect(config.subscription_id).to eq(@config[:subscription_id])
    end

    it 'should return the management_certificate from the config file' do
      expect(config.management_certificate).to eq(@config[:management_certificate])
    end
  end

  context 'with no environment variables and a valid config file present' do
    let(:config) { PuppetX::Puppetlabs::Azure::Config.new(config_file_path) }

    before(:all) do
      @config = {
        subscription_id: 'abc123',
        management_certificate: '/fake/path',
      }
      @path = File.join(Dir.pwd, '.puppet_azure.conf')
      create_config_file(@path, @config)
      nil_environment_variables
    end

    after(:all) do
      File.delete(@path)
    end

    it 'should return the subscription_id from the config file' do
      expect(config.subscription_id).to eq(@config[:subscription_id])
    end

    it 'should return the management_certificate from the config file' do
      expect(config.management_certificate).to eq(@config[:management_certificate])
    end
  end

  context 'with no environment variables or config file' do
    before(:all) do
      nil_environment_variables
    end

    it 'should raise a suitable error' do
      expect do
        PuppetX::Puppetlabs::Azure::Config.new
      end.to raise_error(Puppet::Error, /You must provide credentials in either environment variables or a config file/)
    end
  end

  context 'with incomplete configuration in environment variables' do
    before(:all) do
      ENV['AZURE_SUBSCRIPTION_ID'] = nil
    end

    it 'should raise an error about the missing variables' do
      expect do
        PuppetX::Puppetlabs::Azure::Config.new
      end.to raise_error(Puppet::Error, /You must provide credentials in either environment variables or a config file./)
    end
  end

  context 'with no environment variables and an incomplete config file' do
    before(:all) do
      @config = {
        tenant_id: '995e062e-4f67-4189-8943-595dadd1bccf'
      }
      @path = File.join(Dir.pwd, '.puppet_azure.conf')
      create_incomplete_config_file(@path, @config)
      nil_environment_variables
    end

    after(:all) do
      File.delete(@path)
    end

    it 'should raise an error about the missing variables' do
      expect do
        PuppetX::Puppetlabs::Azure::Config.new(@path)
      end.to raise_error(Puppet::Error, /To use this module you must provide the following settings: subscription_id/)
    end
  end

  context 'with no environment variables and an invalid config file' do
    before(:all) do
      @config = {
        subscription_id: 'abc123',
        management_certificate: nil,
      }
      @path = File.join(Dir.pwd, '.puppet_azure.conf')
      create_config_file(@path, @config)
      nil_environment_variables
    end

    after(:all) do
      File.delete(@path)
    end

    it 'should raise an error about the invalid config file' do
      expect do
        PuppetX::Puppetlabs::Azure::Config.new(config_file_path)
      end.to raise_error(Puppet::Error, /Your configuration file at .+ is invalid/)
    end
  end
end
