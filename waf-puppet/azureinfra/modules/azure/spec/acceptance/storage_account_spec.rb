require 'spec_helper_acceptance'

describe 'azure_storage_account when creating a storage account' do
  include_context 'with a known name and storage account name'
  include_context 'destroy left-over created ARM resources after use'

  before(:all) do
    @client = AzureARMHelper.new
    @name = @client.get_simple_name(@name)
    @config = {
      name: @name,
      ensure: 'present',
      optional: {
        location: CHEAPEST_ARM_LOCATION,
        resource_group: SPEC_RESOURCE_GROUP,
        account_type: 'Standard_GRS',
        account_kind: 'Storage',
      },
    }
    @template = 'azure_storage_account.pp.tmpl'
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_storage_account(@name)
  end

  it_behaves_like 'an idempotent resource'

  it 'should have the correct name' do
    expect(@machine.name).to eq(@name)
  end

  context 'when puppet resource is run' do
    include_context 'a puppet ARM resource run', 'azure_storage_account'
    puppet_resource_should_show('ensure', 'present')
    puppet_resource_should_show('location', 'eastus')
    puppet_resource_should_show('account_type', 'Standard_GRS')
    puppet_resource_should_show('account_kind', 'Storage')
    puppet_resource_should_show('resource_group', SPEC_RESOURCE_GROUP.downcase)
  end

  context 'when we try and destroy the SA' do
    before(:all) do
      new_config = @config.update({:ensure => 'absent'})
      manifest = PuppetManifest.new(@template, new_config)
      @result = manifest.execute
      @machine = @client.get_storage_account(@name)
    end

    it 'should run without errors' do
      expect(@result.exit_code).to eq 2
    end

    it 'should be destroyed' do
      expect(@machine).to be_nil
    end
  end
end
