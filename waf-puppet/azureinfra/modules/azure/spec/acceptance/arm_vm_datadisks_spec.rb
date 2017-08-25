require 'spec_helper_acceptance'

describe 'azure_vm when creating a machine with datadisks' do
  include_context 'with a known name and storage account name'
  include_context 'destroy left-over created ARM resources after use'

  before(:all) do
    @config = {
      name: @name,
      ensure: 'present',
      location: CHEAPEST_ARM_LOCATION,
      resource_group: SPEC_RESOURCE_GROUP,
      optional: {
        image: 'CoreOS:CoreOS:Stable:latest',
        network_interface_name: 'diskspec01',
        os_disk_caching: 'ReadWrite',
        os_disk_create_option: 'FromImage',
        os_disk_name: 'osdisk01',
        os_disk_vhd_container_name: 'conttest1',
        os_disk_vhd_name: 'osvhdtest1',
        size: 'Standard_DS1_v2',
        user: 'specuser',
        password: 'SpecPass123!@#$%',
      },
      nonstring: {
        data_disks: {
          'spec1' => {
            'caching'       => 'ReadWrite',
            'disk_size_gb'  => '15',
            'lun'           => '1',
            'vhd'           => 'https://slowspacespec.blob.core.windows.net/wat/another.vhd',
          },
          'spec2' => {
            'caching'       => 'ReadOnly',
            'create_option' => 'Empty',
            'disk_size_gb'  => '128',
            'lun'           => '0',
            'vhd'           => 'https://hunnerdisks861.blob.core.windows.net/vhds/some_name_here.vhd',
          },
        },
      },
    }
    @template = 'azure_data_disks.pp.tmpl'
    @client = AzureARMHelper.new
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_vm(@name)
  end

  it_behaves_like 'an idempotent resource'

  it 'should have the correct name' do
    expect(@machine.name).to eq(@name)
  end

  it 'should have the correct size' do
    expect(@machine.properties.hardware_profile.vm_size).to eq(@config[:optional][:size])
  end

  it 'should be running' do
    expect(@client.vm_running?(@machine)).to be true
  end

  context 'when we try and change the disks' do
    before(:all) do
      @config[:nonstring][:data_disks]['spec2']['caching'] = 'ReadWrite'
      @manifest = PuppetManifest.new(@template, @config)
      @result = @manifest.execute
      @machine = @client.get_vm(@name)
    end

    it_behaves_like 'an idempotent resource'

    context 'when looked for using puppet resource' do
      include_context 'a puppet ARM resource run'
      puppet_resource_should_show('caching', 'ReadWrite')
    end
  end
end
