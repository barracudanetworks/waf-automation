require 'spec_helper_acceptance'

describe 'azure_vm_classic when creating a multirole services' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'
  include_context 'with known network'

  before(:all) do
    @second_name = @name[0..-2] + "x"
    @third_name = @name[0..-2] + "y"

    @config = {
      optional: {
        user: 'specuser',
        password: 'SpecPass123!@#$%',
      }
    }

    @manifest = <<CONFIG
    azure_vm_classic {
      "#{@name}":
        ensure          => 'present',
        image           => "#{UBUNTU_IMAGE}",
        location        => "#{CHEAPEST_CLASSIC_LOCATION}",
        user            => '#{@config[:optional][:user]}',
        password        => '#{@config[:optional][:password]}',
        size            => 'Small',
        cloud_service   => "#{SPEC_CLOUD_SERVICE}",
        purge_disk_on_delete => true,
        custom_data     => "touch /tmp/#{@name}",
        storage_account => "#{@storage_account_name}",
        virtual_network => "#{@virtual_network_name}",
        subnet          => "#{@network.subnets.first[:name]}",
        endpoints       => [{
          name        => 'ssh',
          local_port  => 22,
          public_port => 2201,
          protocol    => 'TCP',
        }],
    }
    azure_vm_classic {
      "#{@second_name}":
        ensure          => 'present',
        image           => "#{UBUNTU_IMAGE}",
        location        => "#{CHEAPEST_CLASSIC_LOCATION}",
        user            => '#{@config[:optional][:user]}',
        password        => '#{@config[:optional][:password]}',
        size            => 'Small',
        cloud_service   => "#{SPEC_CLOUD_SERVICE}",
        purge_disk_on_delete => true,
        custom_data     => "touch /tmp/#{@second_name}",
        storage_account => "#{@storage_account_name}",
        virtual_network => "#{@virtual_network_name}",
        subnet          => "#{@network.subnets.first[:name]}",
        endpoints       => [{
          name        => 'ssh',
          local_port  => 22,
          public_port => 2202,
          protocol    => 'TCP',
        }],
    }
CONFIG

    @result = execute_manifest(@manifest, beaker_opts)

    @machine = @client.get_virtual_machine(@name).first
    @ip = @machine.ipaddress if @machine

    @second_machine = @client.get_virtual_machine(@second_name).first
  end

  it_behaves_like 'an idempotent resource'

  describe 'the first machine' do
    it 'is accessible on its own port' do
      # What this should really test is the availability of the custom_data file to
      # verify that we're on the right machine. This would require polling until the
      # cloud init has run and make this much more complicated to shore up against
      # a very unlikely error.
      result = run_command_over_ssh(@ip, "true", 'password', 2201)
      expect(result.exit_status).to eq 0
    end
  end

  describe 'the second machine' do
    it 'is accessible on its own port' do
      result = run_command_over_ssh(@ip, "true", 'password', 2202)
      expect(result.exit_status).to eq 0
    end
  end

  context 'when adding another machine to the cloud service' do
    before(:all) do
      @manifest = <<CONFIG
      azure_vm_classic {
        "#{@third_name}":
          ensure          => 'present',
          image           => "#{UBUNTU_IMAGE}",
          location        => "#{CHEAPEST_CLASSIC_LOCATION}",
          user            => '#{@config[:optional][:user]}',
          password        => '#{@config[:optional][:password]}',
          size            => 'Small',
          cloud_service   => "#{SPEC_CLOUD_SERVICE}",
          purge_disk_on_delete => true,
          custom_data     => "touch /tmp/#{@third_name}",
          storage_account => "#{@storage_account_name}",
          virtual_network => "#{@virtual_network_name}",
          subnet          => "#{@network.subnets.first[:name]}",
          endpoints       => [{
            name        => 'ssh',
            local_port  => 22,
            public_port => 2203,
            protocol    => 'TCP',
          }],
      }
CONFIG

      @result = execute_manifest(@manifest, beaker_opts)

      @machine = @client.get_virtual_machine(@name).first
      @second_machine = @client.get_virtual_machine(@second_name).first
      @third_machine = @client.get_virtual_machine(@third_name).first
    end

    it_behaves_like 'an idempotent resource'

    describe 'the first machine' do
      it 'is accessible on its own port' do
        result = run_command_over_ssh(@ip, "true", 'password', 2201)
        expect(result.exit_status).to eq 0
      end
    end

    describe 'the second machine' do
      it 'is accessible on its own port' do
        result = run_command_over_ssh(@ip, "true", 'password', 2202)
        expect(result.exit_status).to eq 0
      end
    end
    describe 'the third machine' do
      it 'is accessible on its own port' do
        result = run_command_over_ssh(@ip, "true", 'password', 2203)
        expect(result.exit_status).to eq 0
      end
    end
  end

  describe 'removing a single machine' do
    before(:all) do
      @manifest = <<CONFIG
      azure_vm_classic {
        "#{@second_name}":
          ensure        => 'absent',
          location      => "#{CHEAPEST_CLASSIC_LOCATION}",
          cloud_service => "#{SPEC_CLOUD_SERVICE}",
          purge_disk_on_delete => true,
      }
CONFIG

      @result = execute_manifest(@manifest, beaker_opts)

      @machine = @client.get_virtual_machine(@name).first
      @second_machine = @client.get_virtual_machine(@second_name).first
      @third_machine = @client.get_virtual_machine(@third_name).first
    end

    it 'runs successfully' do
      expect(@result.exit_code).to eq 2
    end

    it 'removes the machine' do
      expect(@second_machine).to be_nil
    end

    describe 'the first machine' do
      it 'is still accessible on its own port' do
        result = run_command_over_ssh(@ip, "true", 'password', 2201)
        expect(result.exit_status).to eq 0
      end
    end

    describe 'the third machine' do
      it 'is still accessible on its own port' do
        result = run_command_over_ssh(@ip, "true", 'password', 2203)
        expect(result.exit_status).to eq 0
      end
    end

    describe 'removing all machines' do
      before(:all) do
        @manifest = <<CONFIG
        azure_vm_classic {
          [ "#{@name}", "#{@second_name}", "#{@third_name}" ]:
            ensure        => 'absent',
            location      => '#{CHEAPEST_CLASSIC_LOCATION}',
            cloud_service => "#{SPEC_CLOUD_SERVICE}",
            purge_disk_on_delete => true,
        }
CONFIG

        @result = execute_manifest(@manifest, beaker_opts)

        @machine = @client.get_virtual_machine(@name).first
        @second_machine = @client.get_virtual_machine(@second_name).first
        @third_machine = @client.get_virtual_machine(@third_name).first
      end

      it 'runs successfully' do
        expect(@result.exit_code).to eq 2
      end

      it 'removes all machines' do
        expect(@machine).to be_nil
        expect(@second_machine).to be_nil
        expect(@third_machine).to be_nil
      end
    end
  end
end
