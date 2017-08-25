require 'spec_helper_acceptance'

describe 'azure_resource_template when creating a template deployment' do
  include_context 'with a known name and storage account name'
  include_context 'destroy left-over created ARM resources after use'

  before(:all) do
    @client = AzureARMHelper.new
    @name = @client.get_simple_name(@name)
    @config = {
      name: @name,
      ensure: 'present',
      resource_group: SPEC_RESOURCE_GROUP,
      location: CHEAPEST_ARM_LOCATION,
      optional: {}, #XXX fails without this
      nonstring: {
        content: '$content',
        params: {
          'dnsNameforLBIP'      => 'stuffandthings02',
          'publicIPAddressType' => 'Dynamic',
          'addressPrefix'       => '10.0.0.0/16',
          'subnetPrefix'        => '10.0.0.0/24',
        },
      },
    }
    @template = 'azure_resource_template.pp.tmpl'
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_resource_template(SPEC_RESOURCE_GROUP,@name)
  end

  it_behaves_like 'an idempotent resource'

  it 'should have the correct name' do
    expect(@machine.name).to eq(@name)
  end

  context 'when puppet resource is run' do
    include_context 'a puppet ARM resource run', 'azure_resource_template'
    puppet_resource_should_show('ensure', 'present')
    puppet_resource_should_show('resource_group',SPEC_RESOURCE_GROUP)
    puppet_resource_should_show('params', '')
  end

  context 'when we try and destroy the deployment' do
    before(:all) do
      new_config = @config.update({:ensure => 'absent'})
      manifest = PuppetManifest.new(@template, new_config)
      @result = manifest.execute
      @machine = @client.get_resource_template(SPEC_RESOURCE_GROUP,@name)
    end

    it 'should run without errors' do
      expect(@result.exit_code).to eq 2
    end

    it 'should be destroyed' do
      expect(@machine).to be_nil
    end
  end
end
