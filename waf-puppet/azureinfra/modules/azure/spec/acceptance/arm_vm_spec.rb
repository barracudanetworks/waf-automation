require 'spec_helper_acceptance'

describe 'azure_vm when creating a machine with all available properties' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'
  include_context 'destroy left-over created ARM resources after use'

  before(:all) do
    @custom_data_file = '/tmp/needle'
    @extension_file = '/tmp/extensionz'
    @config = {
      name: @name,
      ensure: 'present',
      optional: {
        image: 'canonical:ubuntuserver:14.04.2-LTS:latest',
        location: CHEAPEST_ARM_LOCATION,
        user: 'specuser',
        size: 'Standard_A0',
        resource_group: SPEC_RESOURCE_GROUP,
        password: 'SpecPass123!@#$%',
        storage_account: @storage_account_name,
        storage_account_type: 'Standard_GRS',
        os_disk_name: 'osdisk01',
        os_disk_caching: 'ReadWrite',
        os_disk_create_option: 'FromImage',
        os_disk_vhd_container_name: 'conttest1',
        os_disk_vhd_name: 'osvhdtest1',
        dns_domain_name: 'puppetspecdomain01',
        dns_servers: '8.8.8.8 8.8.4.4',
        public_ip_allocation_method: 'Dynamic',
        public_ip_address_name: 'ip_name_test01pubip',
        virtual_network_name: 'vnettest01',
        virtual_network_address_space: '10.0.0.0/16',
        custom_data: "touch #{@custom_data_file}",
        subnet_name: 'subnet111',
        subnet_address_prefix: '10.0.2.0/24',
        ip_configuration_name: 'ip_config_test01',
        private_ip_allocation_method: 'Dynamic',
        network_interface_name: 'nicspec01',
      },
      nonstring: {
        extensions: {
          'CustomScriptForLinux' => {
            'auto_upgrade_minor_version' => false,
            'publisher'                  => 'Microsoft.OSTCExtensions',
            'type'                       => 'CustomScriptForLinux',
            'type_handler_version'       => '1.4',
            'settings'                   => {
              'commandToExecute' => "touch #{@extension_file}",
            },
          },
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

  it 'should have the correct size' do
    expect(@machine.properties.hardware_profile.vm_size).to eq(@config[:optional][:size])
  end

  it 'should be running' do
    expect(@client.vm_running?(@machine)).to be true
  end

  it 'should have run the extension' do
    # It's possible to get an SSH connection before cloud-init kicks in and sets the file.
    # so we retry this a few times
    5.times do
      @result = run_command_over_ssh(@ip, "test -f #{@extension_file}", 'password', 22)
      break if @result.exit_status.zero?
      sleep 10
    end
    expect(@result.exit_status).to eq 0
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

  context 'when puppet resource is run' do
    include_context 'a puppet ARM resource run'
    puppet_resource_should_show('ensure', 'running')
    puppet_resource_should_show('location', 'eastus')
    puppet_resource_should_show('image')
    puppet_resource_should_show('user')
    puppet_resource_should_show('size')
    puppet_resource_should_show('resource_group')
    puppet_resource_should_show('network_interface_name')
    puppet_resource_should_show('os_disk_vhd_container_name')
    puppet_resource_should_show('os_disk_vhd_name')
    puppet_resource_should_show('extensions')
  end

  context 'when we try and stop the VM' do
    before(:all) do
      new_config = @config.update({:ensure => 'stopped'})
      @manifest = PuppetManifest.new(@template, new_config)
      @result = @manifest.execute
      @machine = @client.get_vm(@name)
    end

    it_behaves_like 'an idempotent resource'

    it 'should be stopped' do
      expect(@client.vm_stopped?(@machine)).to be true
    end

    context 'when looked for using puppet resource' do
      include_context 'a puppet ARM resource run'
      puppet_resource_should_show('ensure', 'stopped')
    end

    context 'when we try and restart the VM' do
      before(:all) do
        new_config = @config.update({:ensure => 'running'})
        @manifest = PuppetManifest.new(@template, new_config)
        @result = @manifest.execute
        @machine = @client.get_vm(@name)
      end

      it_behaves_like 'an idempotent resource'

      it 'should be running' do
        expect(@client.vm_running?(@machine)).to be true
      end

      context 'when looked for using puppet resource' do
        include_context 'a puppet ARM resource run'
        puppet_resource_should_show('ensure', 'running')
      end
    end
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
