require 'spec_helper_acceptance'

describe 'azure_vm_classic when creating a machine with all available properties' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'
  include_context 'with known network'
  include_context 'with temporary affinity group'

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
        storage_account: @storage_account_name, # required in order to tidy up created storage groups
        affinity_group: @affinity_group_name, # tested here to avoid clash with virtual_network
      },
      endpoints: [{
        name: 'ssh',
        local_port: 22,
        public_port: 22,
        protocol: 'TCP',
        direct_server_return: false,
      }],
    }

    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_virtual_machine(@name).first
    @ip = @machine.ipaddress
  end

  it_behaves_like 'an idempotent resource'

  include_context 'destroy left-over created resources after use'

  it 'is accessible using the password' do
    result = run_command_over_ssh(@ip, 'true', 'password', 22)
    expect(result.exit_status).to eq 0
  end

  it 'should have the correct SSH port' do
    ssh_endpoint = @machine.tcp_endpoints.find { |endpoint| endpoint[:name].casecmp('ssh').zero? }
    expect(ssh_endpoint).not_to be_nil
    expect(ssh_endpoint[:public_port].to_i).to eq(22)
  end

  pending 'Azure API support required for non-default ports for load balancing' do
    context 'when configuring a load balancer for ssh on a non-default port' do
      before(:all) do
        # replace the existing endpoint
        @config[:endpoints] = [{
            name: 'SSH',
            local_port: 22,
            public_port: 2200,
            protocol: 'TCP',
            direct_server_return: false,
            load_balancer_name: 'ssh-lb',
            load_balancer: {
              port: 22,
              protocol: 'tcp',
              interval: 2,
            }
          }]

        @manifest = PuppetManifest.new(@template, @config)
        @result = @manifest.execute
      end

      it_behaves_like 'an idempotent resource'

      it 'is accessible using the new port' do
        pending 'Azure API support required for non-default ports for load balancing'
        result = run_command_over_ssh(@ip, 'true', 'password', 2200)
        expect(result.exit_status).to eq 0
      end

      context 'after deleting the endpoint' do
        pending 'Azure API support required for non-default ports for load balancing'
        before(:all) do
          @config[:endpoints] = []
          @manifest = PuppetManifest.new(@template, @config)
          @result = @manifest.execute
        end

        #This shared context will be needed when the test is reintroduced.
        #it_behaves_like 'an idempotent resource'

        # Since the last tests verified that we can talk to the VM,
        # this will check that the port is now closed. Obviously
        # this is a race against network failures.
        it 'is not accessible anymore' do
          expect do
            with_retries(:max_tries => 2,
                         :base_sleep_seconds => 2,
                         :max_sleep_seconds => 20,
                         :rescue => [PuppetX::Puppetlabs::Azure::NotFinished]) do
              Net::SSH.start(@ip,
                             @config[:optional][:user],
                             :port => 22,
                             :password => @config[:optional][:password],
                             :auth_methods => ['password'],
                             :verbose => :info) do |ssh|
                SshExec.ssh_exec!(ssh, 'true')
              end
              # Wait for Azure to reconfigure the endpoint
              raise PuppetX::Puppetlabs::Azure::NotFinished.new
            end
          end.to raise_error(Errno::ETIMEDOUT)
        end
      end
    end
  end
  it_behaves_like 'a removable resource'
end
