require 'spec_helper_acceptance'

describe 'azure_resource_group when creating a resource group' do
  include_context 'with a known name and storage account name'
  include_context 'destroy left-over created ARM resources after use'

  before(:all) do
    @config = {
      name: @name,
      ensure: 'present',
      location: CHEAPEST_ARM_LOCATION,
      optional: {}
    }
    @template = 'azure_resource_group.pp.tmpl'
    @client = AzureARMHelper.new
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_resource_group(@name)
  end

  it_behaves_like 'an idempotent resource'

  it 'should have the correct name' do
    expect(@machine.name).to eq(@name)
  end

  context 'when puppet resource is run' do
    include_context 'a puppet ARM resource run', 'azure_resource_group'
    puppet_resource_should_show('ensure', 'present')
    puppet_resource_should_show('location', 'eastus')
  end

  context 'when we try and destroy the RG' do
    before(:all) do
      new_config = @config.update({:ensure => 'absent'})
      manifest = PuppetManifest.new(@template, new_config)
      @result = manifest.execute
      @machine = @client.get_resource_group(@name.downcase)
    end

    it 'should run without errors' do
      expect(@result.exit_code).to eq 2
    end

    it 'should be destroyed' do
      expect(@machine).to be_nil
    end
  end
end
