require 'spec_helper_acceptance'

describe 'azure_vm_classic when creating a machine with all available properties' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'
  include_context 'with known network'

  before(:all) do
    @custom_data_file = '/tmp/needle'
    @config = {
      name: @name,
      ensure: 'present',
      optional: {
        image: UBUNTU_IMAGE,
        location: CHEAPEST_CLASSIC_LOCATION,
        user: 'specuser',
        password: 'SpecPass123!@#$%',
        size: 'Small',
        deployment: "CLOUD-DN-#{SecureRandom.hex(8)}",
        cloud_service: SPEC_CLOUD_SERVICE,
        data_disk_size_gb: 53,
        purge_disk_on_delete: true,
        custom_data: "touch #{@custom_data_file}",
        storage_account: @storage_account_name,
        virtual_network: @virtual_network_name,
        subnet: @network.subnets.first[:name],
        availability_set: "CLOUD-AS-#{SecureRandom.hex(8)}",
      }
    }

    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_virtual_machine(@name).first
    @ip = @machine.ipaddress
  end

  it_behaves_like 'an idempotent resource'

  include_context 'destroy left-over created resources after use'

  it 'should have the correct size' do
    expect(@machine.role_size).to eq(@config[:optional][:size])
  end

  it 'should have the correct deployment name' do
    expect(@machine.deployment_name).to eq(@config[:optional][:deployment])
  end

  it 'should have the correct cloud service name' do
    expect(@machine.cloud_service_name).to eq(@config[:optional][:cloud_service])
  end

  describe 'the data disk' do
    it 'should be attached' do
      expect(@machine.data_disks.count).to eq 1
    end

    it 'should have the correct size' do
      expect(@machine.data_disks.first[:size_in_gb].to_i).to eq @config[:optional][:data_disk_size_gb]
    end

    pending 'should be able to grow on the fly'
  end

  it 'should be associated with the correct network' do
    expect(@machine.virtual_network_name).to eq(@config[:optional][:virtual_network])
  end

  it 'should be associated with the correct subnet' do
    expect(@machine.subnet).to eq(@config[:optional][:subnet])
  end

  it 'is accessible using the password' do
    result = run_command_over_ssh(@ip, 'true', 'password', 22)
    expect(result.exit_status).to eq 0
  end

  it 'should have run the custom data script' do
    # It's possible to get an SSH connection before cloud-init kicks in and sets the file.
    # so we retry this a few times
    5.times do
      @result = run_command_over_ssh(@ip, "test -f #{@custom_data_file}", 'password', 22)
      break if @result.exit_status.zero?
      sleep 10
    end
    expect(@result.exit_status).to eq 0
  end

  it 'should be in the correct storage account' do
    storage_account = @client.get_storage_account(@config[:optional][:storage_account])
    expect(storage_account.label).to eq(@config[:optional][:cloud_service])
  end

  it 'should have the correct availability set' do
    expect(@machine.availability_set_name).to eq(@config[:optional][:availability_set])
  end

  context 'which has read-only properties' do
    read_only = [
      :location,
      :deployment,
      :cloud_service,
      :size,
      :image,
      :virtual_network,
      :availability_set,
    ]

    read_only.each do |new_config_value|
      it "should prevent change to read-only property #{new_config_value}" do
        config_clone = Marshal.load(Marshal.dump(@config))
        config_clone[:optional][new_config_value.to_sym] = 'foo'
        expect_failed_apply(config_clone)
      end
    end
  end

  context 'when looked for using puppet resource' do
    include_context 'a puppet resource run'
    puppet_resource_should_show('size')
    puppet_resource_should_show('deployment')
    puppet_resource_should_show('cloud_service')
    puppet_resource_should_show('availability_set')
  end

  it_behaves_like 'a removable resource'
end
