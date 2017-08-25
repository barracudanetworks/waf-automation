require 'spec_helper_acceptance'

describe 'azure_vm_classic when creating a new machine with the minimum properties' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'
  include_context 'with temporary affinity group'

  before(:all) do
    @config = {
      name: @name,
      ensure: 'present',
      optional: {
        image: UBUNTU_IMAGE,
        location: CHEAPEST_CLASSIC_LOCATION,
        user: 'specuser',
        private_key_file: @remote_private_key_path,
        storage_account: @storage_account_name, # required in order to tidy up created storage groups
        affinity_group: @affinity_group_name, # tested here to avoid clash with virtual_network
      }
    }
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_virtual_machine(@name).first
    @ip = @machine.ipaddress
  end

  it_behaves_like 'an idempotent resource'

  include_context 'destroy left-over created resources after use'

  it 'should have the correct image' do
    expect(@machine.image).to eq(@config[:optional][:image])
  end

  it 'should have the default size' do
    expect(@machine.role_size).to eq('Small')
  end

  it 'should be launched in the specified location' do
    cloud_service = @client.get_cloud_service(@machine)
    location = cloud_service.location || cloud_service.extended_properties["ResourceLocation"]
    expect(location).to eq(@config[:optional][:location])
  end

  it 'should have the default SSH port' do
    ssh_endpoint = @machine.tcp_endpoints.find { |endpoint| endpoint[:name] == 'SSH' }
    expect(ssh_endpoint[:public_port]).to eq('22')
  end

  it 'is accessible using the private key' do
    result = run_command_over_ssh(@ip, 'true', 'publickey')
    expect(result.exit_status).to eq 0
  end

  it 'is able to use sudo to root' do
    result = run_command_over_ssh(@ip, 'sudo true', 'publickey')
    expect(result.exit_status).to eq 0
  end

  it 'should be in the correct affinity group' do
    affinity_group = @client.get_affinity_group(@affinity_group_name)
    associated_services = affinity_group.hosted_services.map { |service| service[:service_name] }
    expect(associated_services).to include(@machine.cloud_service_name)
  end

  # this primarily tests that the image we use for testing does not add its own data disks,
  # which could confuse the other tests for data_disk_size_gb
  describe 'the image' do
    it 'has no data disk' do
      expect(@machine.data_disks).to be_empty
    end
  end

  pending 'should be able to attach a disk on the fly'

  context 'stopping the machine' do
    before(:all) do
      new_config = @config.update({:ensure => 'stopped'})
      @manifest = PuppetManifest.new(@template, new_config)
      @result = @manifest.execute
      @stopped_machine = @client.get_virtual_machine(@name).first
    end

    it_behaves_like 'an idempotent resource'

    it 'should be stopped' do
      expect(@stopped_machine.status).to eq('StoppedDeallocated')
    end

    context 'restarting the machine' do
      before(:all) do
        new_config = @config.update({:ensure => 'running'})
        @manifest = PuppetManifest.new(@template, new_config)
        @result = @manifest.execute
        @started_machine = @client.get_virtual_machine(@name).first
      end

      it_behaves_like 'an idempotent resource'

      it 'should not be stopped' do
        # Machines first enter an unknown state (RoleStateUnknown) before being
        # marked as ready (ReadyRole). This can take time so rather than always
        # wait for ready we're happy that we've changed the machine from stopped.
        expect(@started_machine.status).not_to eq('StoppedDeallocated')
      end
    end
  end

  context 'when looked for using puppet resource' do
    include_context 'a puppet resource run'
    puppet_resource_should_show('ensure', 'running')
    puppet_resource_should_show('location')
    puppet_resource_should_show('size', 'Small')
    puppet_resource_should_show('image')
    puppet_resource_should_show('os_type')
    puppet_resource_should_show('ipaddress')
    puppet_resource_should_show('media_link')
  end

  it_behaves_like 'a removable resource'
end
