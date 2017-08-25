require 'spec_helper_acceptance'

describe 'azure_vm when creating a machine with a plan' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'
  include_context 'destroy left-over created ARM resources after use'

  before(:all) do
    @custom_data_file = '/tmp/needle'
    @config = {
      name: @name,
      ensure: 'present',
      optional: {
        location: CHEAPEST_ARM_LOCATION,
        user: 'specuser',
        size: 'Standard_A0',
        resource_group: SPEC_RESOURCE_GROUP,
        password: 'SpecPass123!@#$%',
      },
      nonstring: {
        plan: {
          'name'      => '2016-1',
          'product'   => 'puppet-enterprise',
          'publisher' => 'puppet',
        },
      },
    }
    @template = 'azure_vm.pp.tmpl'
    @client = AzureARMHelper.new
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_vm(@name)
    @ip = @client.get_public_ip_address(
      SPEC_RESOURCE_GROUP,
      @client.get_network_interface(
        SPEC_RESOURCE_GROUP,
        @machine.properties.network_profile.network_interfaces.first.id.split('/').last
      ).properties.ip_configurations.first.properties.public_ipaddress.id.split('/').last
    ).properties.ip_address
  end

  it_behaves_like 'an idempotent resource'

  it 'should have the correct name' do
    expect(@machine.name).to eq(@name)
  end

  it 'should be running' do
    expect(@client.vm_running?(@machine)).to be true
  end

  context 'when puppet resource is run' do
    include_context 'a puppet ARM resource run'
    puppet_resource_should_show('ensure', 'running')
    puppet_resource_should_show('location', 'eastus')
    puppet_resource_should_show('plan')
    puppet_resource_should_show('user')
    puppet_resource_should_show('size')
    puppet_resource_should_show('resource_group')
  end

  context 'when we try and destroy the VM' do
    before(:all) do
      new_config = @config.update({:ensure => 'absent'})
      manifest = PuppetManifest.new(@template, new_config)
      @result = manifest.execute
      @machine = @client.get_vm(@name)
    end

    it 'should run without errors' do
      expect(@result.exit_code).to eq 2
    end

    it 'should be destroyed' do
      expect(@machine).to be_nil
    end
  end
end
