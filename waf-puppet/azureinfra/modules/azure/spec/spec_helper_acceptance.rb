
require 'azure'
require 'mustache'
require 'open3'
require 'master_manipulator'
require 'beaker'
require 'beaker-rspec' if ENV['BEAKER_TESTMODE'] != 'local'
require 'beaker/puppet_install_helper'
require 'beaker/testmode_switcher/dsl'
require 'net/ssh'
require 'ssh-exec'
require 'retries'
require 'shellwords'
require 'winrm'

require 'puppet_x/puppetlabs/azure/config'
require 'puppet_x/puppetlabs/azure/not_finished'

require 'azure_mgmt_compute'
require 'azure_mgmt_resources'
require 'azure_mgmt_storage'
require 'azure_mgmt_network'
require 'ms_rest_azure'

# automatically load any shared examples or contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

# Workaround https://github.com/Azure/azure-sdk-for-ruby/issues/269
require 'azure/core'
require 'azure/virtual_machine_image_management/virtual_machine_image_management_service'

# cheapest as of 2015-08
CHEAPEST_ARM_LOCATION="eastus".freeze
CHEAPEST_CLASSIC_LOCATION="East US".freeze

# For personal resource groups
SPEC_RESOURCE_GROUP="CLOUD-ARM-#{ENV['USER'] || 'tests'}".freeze
SPEC_CLOUD_SERVICE="CLOUD-CS-#{ENV['USER'] || 'tests'}".freeze

UBUNTU_IMAGE='b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_3-LTS-amd64-server-20150908-en-us-30GB'.freeze
WINDOWS_IMAGE='a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20160126-en.us-127GB.vhd'.freeze

CERT_FILE='azure_cert.pem'.freeze
WINDOWS_AZURE_CERT="/cygdrive/c/#{CERT_FILE}".freeze
LINUX_AZURE_CERT="/tmp/#{CERT_FILE}".freeze
WINDOWS_DOS_FORMAT_AZURE_CERT="c:\\#{CERT_FILE}".freeze

# windows module install path
# /cygdrive/c/ProgramData/PuppetLabs/code/modules
#
RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
  c.before :suite do
    unless ENV['BEAKER_TESTMODE'] == 'local'
      unless ENV['BEAKER_provision'] == 'no'
        run_puppet_install_helper

        hosts.each do |host|
          if host['platform'] =~ /^el/
            on(host, 'yum install -y zlib-devel patch gcc-c++')
          elsif host['platform'] =~ /^ubuntu|^debian/
            on(host, 'apt-get install -y zlib1g-dev patch g++')
          end

          gems = [
              # Unf has a separate gem for it's native extensions, unf_ext. Unf_ext has windows packages with the precompiled
              # libraries. Because of this setup just installing the top level azure gems doesn't always seem to do the
              # right thing on Windows
            [ 'unf' ],
            [ 'hocon', 'retries' ],
            # Azure gems require pinning because they are still under heavy development and change their API frequently
            [ 'azure_mgmt_compute', '--version=~> 0.3.0' ],
            [ 'azure_mgmt_network', '--version=~> 0.3.0' ],
            [ 'azure_mgmt_resources', '--version=~> 0.3.0' ],
            [ 'azure_mgmt_storage', '--version=~> 0.3.0' ],
            [ 'azure', '--version=~> 0.7.0' ],
          ]

          additional_gem_opts = ["--no-ri", "--no-rdoc"]

          if is_windows?(host)
            # shield the quoting from beaker's autoquoting to correctly quote the space
            # also avoid the gem.bat, as that cannot pass arguments with spaces and other special characters through
            windows_cmd = [ '/cygdrive/c/Program Files/Puppet Labs/Puppet/sys/ruby/bin/ruby.exe', 'C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin\gem' , 'install' ]
            gems.each do |args|
              command = (windows_cmd + args + additional_gem_opts).collect { |a| "\\\"#{a}\\\"" }.join(" ")
              on(host, "bash -c \"#{command}\"")
            end
          else
            linux_cmd = [ host.file_exist?("#{host['privatebindir']}/gem") ? "#{host['privatebindir']}/gem" : "#{host['puppetbindir']}/gem" , 'install' ]
            gems.each do |args|
              command = (linux_cmd + (args + additional_gem_opts).collect { |a| "'#{a}'" }).join(" ")
              on(host, command)
            end
          end
        end
      end

      proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      hosts.each do |host|
        # set :target_module_path manually to work around beaker-rspec bug that does not
        # persist distmoduledir across runs with reused nodes
        # TODO: ticket up this bug for beaker-rspec
        module_path = is_windows?(host) ? '/cygdrive/c/ProgramData/PuppetLabs/code/modules' : '/etc/puppetlabs/code/modules'
        install_dev_puppet_module_on(host, :source => proj_root, :module_name => 'azure', :target_module_path => module_path)
      end
    end

    # Deploy Azure credentials
    if ENV['AZURE_MANAGEMENT_CERTIFICATE']
      scp_to_ex(ENV['AZURE_MANAGEMENT_CERTIFICATE'], is_windows? ? WINDOWS_AZURE_CERT : LINUX_AZURE_CERT)
    end
  end
end

class PuppetManifest < Mustache
  attr_accessor :optional_endpoints, :endpoints

  def initialize(file, config) # rubocop:disable Metrics/AbcSize
    @template_file = File.join(Dir.getwd, 'spec', 'acceptance', 'fixtures', file)

    # decouple the config we're munging from the value used in the tests
    config = Marshal.load( Marshal.dump(config) )

    endpoints = config.delete(:endpoints)
    @optional_endpoints = endpoints.is_a?(Array) and !endpoints.empty?
    if @optional_endpoints
      @endpoints = endpoints.collect do |ep|
        lb = ep.delete(:load_balancer)
        {
          values: self.class.to_generalized_data(ep),
          has_load_balancer: !!lb,
          load_balancer: self.class.to_generalized_data(lb),
        }
      end
    end

    config.each do |key, value|
      config_value = self.class.to_generalized_data(value)
      instance_variable_set("@#{key}".to_sym, config_value)
      self.class.send(:attr_accessor, key)
    end
  end

  def execute
    Beaker::TestmodeSwitcher::DSL.execute_manifest(self.render, beaker_opts)
  end

  def self.to_generalized_data(val)
    case val
    when Hash
      to_generalized_hash_list(val)
    when Array
      to_generalized_array_list(val)
    else
      val
    end
  end

  # returns an array of :k =>, :v => hashes given a Hash
  # { :a => 'b', :c => 'd' } -> [{:k => 'a', :v => 'b'}, {:k => 'c', :v => 'd'}]
  def self.to_generalized_hash_list(hash)
    hash.map { |k, v| { :k => k, :v => v }}
  end

  # necessary to build like [{ :values => Array }] rather than [[]] when there
  # are nested hashes, for the sake of Mustache being able to render
  # otherwise, simply return the item
  def self.to_generalized_array_list(arr)
    arr.map do |item|
      if item.class == Hash
        {
          :values => to_generalized_hash_list(item)
        }
      else
        item
      end
    end
  end

  def self.env_id
    @env_id ||= (
      ENV['BUILD_DISPLAY_NAME'] ||
      (ENV['USER'] + '@' + Socket.gethostname.split('.')[0])
    ).delete("'")
  end

  def self.rds_id
    @rds_id ||= (
      ENV['BUILD_DISPLAY_NAME'] ||
      (ENV['USER'])
    ).gsub(/\W+/, '')
  end

  def self.env_dns_id
    @env_dns_id ||= @env_id.gsub(/[^\\dA-Za-z-]/, '')
  end
end

class AzureARMHelper
  def self.config
    PuppetX::Puppetlabs::Azure::Config.new
  end

  def self.compute_client
    @compute_client ||= AzureARMHelper.with_subscription_id ::Azure::ARM::Compute::ComputeManagementClient.new(credentials)
  end

  def self.network_client
    @network_client ||= AzureARMHelper.with_subscription_id ::Azure::ARM::Network::NetworkManagementClient.new(credentials)
  end

  def self.storage_client
    @storage_client ||= AzureARMHelper.with_subscription_id ::Azure::ARM::Storage::StorageManagementClient.new(credentials)
  end

  def self.resource_client
    @resource_client ||= AzureARMHelper.with_subscription_id ::Azure::ARM::Resources::ResourceManagementClient.new(credentials)
  end

  def self.credentials
    token_provider = ::MsRestAzure::ApplicationTokenProvider.new(AzureARMHelper.config.tenant_id, AzureARMHelper.config.client_id, AzureARMHelper.config.client_secret)
    ::MsRest::TokenCredentials.new(token_provider)
  end

  def self.with_subscription_id(client)
    client.subscription_id = AzureARMHelper.config.subscription_id
    client
  end

  def list_resource_providers
    AzureARMHelper.resource_client.providers.list
  end

  def get_resource_group(name)
    resource_groups = AzureARMHelper.resource_client.resource_groups.list
    resource_groups.value.find { |x| x.name == name }
  end

  def destroy_resource_group(resource_group_name)
    AzureARMHelper.resource_client.resource_groups.delete(resource_group_name).value!.body
  end

  def list_resource_templates(resource_group)
    AzureARMHelper.resource_client.deployments.list(resource_group).value
  end

  def get_resource_template(resource_group,name)
    deployments = list_resource_templates(resource_group)
    deployments.find { |x| x.name == name }
  end

  def destroy_resource_template(resource_group_name, name)
    AzureARMHelper.resource_client.deployments.delete(resource_group_name, name).value!.body
  end

  def list_storage_accounts
    AzureARMHelper.storage_client.storage_accounts.list.value
  end

  def get_storage_account(name)
    accounts = list_storage_accounts
    accounts.find { |x| x.name == name }
  end

  def get_network_interface(resource_group, network_interface_name)
    AzureARMHelper.network_client.network_interfaces.get(resource_group, network_interface_name)
  end

  def get_public_ip_address(resource_group, public_ip_address_name)
    AzureARMHelper.network_client.public_ipaddresses.get(resource_group, public_ip_address_name)
  end

  def destroy_storage_account(resource_group_name, name)
    AzureARMHelper.storage_client.storage_accounts.delete(resource_group_name, name)
  end

  def get_all_vms
    vms = AzureARMHelper.compute_client.virtual_machines.list_all.value
    vms.collect do |vm|
      AzureARMHelper.compute_client.virtual_machines.get(get_resource_group_from(vm), vm.name, 'instanceView')
    end
  end

  def get_resource_group_from(machine)
    machine.id.split('/')[4].downcase
  end

  def get_simple_name(value)
    value.downcase.gsub(/[^0-9a-z]/i, '')
  end

  def get_vm(name)
    get_all_vms.find { |vm| vm.name == name }
  end

  def destroy_vm(machine)
    AzureARMHelper.compute_client.virtual_machines.delete(get_resource_group_from_vm(machine), machine.name).value!.body
  end

  def vm_running?(vm)
    ! vm.properties.instance_view.statuses.find { |s| s.code =~ /PowerState\/running/ }.nil?
  end

  def vm_stopped?(vm)
    ! vm.properties.instance_view.statuses.find { |s| s.code =~ /PowerState\/stopped/ }.nil?
  end
end

class AzureHelper
  def initialize
    configuration_from_env_or_file = ::PuppetX::Puppetlabs::Azure::Config.new
    Azure.subscription_id = configuration_from_env_or_file.subscription_id
    Azure.management_certificate = configuration_from_env_or_file.management_certificate

    @azure_vm = Azure.vm_management
    @azure_affinity_group = Azure.base_management
    @azure_cloud_service = Azure.cloud_service_management
    @azure_storage = Azure.storage_management
    @azure_disk = Azure.vm_disk_management
    @azure_network = Azure.network_management
  end

  # This can return > 1 virtual machines if there are naming clashes.
  def get_virtual_machine(name)
    @azure_vm.list_virtual_machines.select { |x| x.vm_name == name }
  end

  def destroy_virtual_machine(machine)
    @azure_vm.delete_virtual_machine(machine.vm_name, machine.cloud_service_name)
  end

  def get_cloud_service(machine)
    @azure_cloud_service.get_cloud_service(machine.cloud_service_name)
  end

  def get_storage_account(name)
    @azure_storage.get_storage_account(name)
  end

  def get_disk(name)
    @azure_disk.get_virtual_machine_disk(name)
  end

  def destroy_disk(name)
    if @azure_disk.get_virtual_machine_disk(name)
      @azure_disk.delete_virtual_machine_disk(name)
    end
  end

  def destroy_storage_account(name)
    @azure_storage.delete_storage_account(name)
  end

  def get_virtual_network(name)
    @azure_network.list_virtual_networks.find { |network| network.name == name }
  end

  def ensure_network(name)
    # This should ideally be create_network, with a corresponding delete_network. However
    # the SDK doesn't support deleteing virtual networks. Nor does the lower-level
    # REST API https://msdn.microsoft.com/en-us/library/azure/jj157182.aspx
    # With that in mind we reuse a known network between tests, which is horrible but works
    # given we don't need to mutate it, just for it to exist
    unless get_virtual_network(name)
      address_space = ['172.16.0.0/12', '10.0.0.0/8', '192.168.0.0/24']
      subnets = [
        {name: "#{name}-1", ip_address: '172.16.0.0', cidr: 12},
        {name: "#{name}-2", ip_address: '10.0.0.0', cidr: 8}
      ]
      dns_servers = [{name: 'dns', ip_address: '1.2.3.4'}]
      options = {:subnet => subnets, :dns => dns_servers}
      @azure_network.set_network_configuration(name, CHEAPEST_CLASSIC_LOCATION, address_space, options)
    end
  end

  def get_affinity_group(name)
    @azure_affinity_group.get_affinity_group(name)
  end

  def create_affinity_group(name)
    @azure_affinity_group.create_affinity_group(name, CHEAPEST_CLASSIC_LOCATION, 'Temporary group for acceptance tests')
  end

  def destroy_affinity_group(name)
    @azure_affinity_group.delete_affinity_group(name)
  end
end

def expect_failed_apply(config)
  result = PuppetManifest.new(@template, config).execute
  expect(result.exit_code).not_to eq 0
end

def run_command_over_ssh(host, command, auth_method, port=22)
  # We retry failed attempts as although the VM has booted it takes some
  # time to start and expose SSH. This mirrors the behaviour of a typical SSH client
  allowed_errors = [
    # The following errors can occur if we try and connect after the machine has
    # been created but before cloud-init provisions the machine
    Net::SSH::HostKeyMismatch,
    Net::SSH::AuthenticationFailed,
    # The following errors can occur before the machine has been created
    # and we retry until it exists
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::ETIMEDOUT,
  ]
  handler = Proc.new do |exception, attempt_number, total_delay|
    puts "Handler saw a #{exception.class}; retry attempt #{attempt_number}; #{total_delay} seconds have passed."
    puts exception
  end
  with_retries(:max_tries => 10,
               :base_sleep_seconds => 20,
               :max_sleep_seconds => 20,
               :rescue => allowed_errors,
               :handler => handler) do
    Net::SSH.start(host,
                   @config[:optional][:user],
                   :port => port,
                   :password => @config[:optional][:password],
                   :keys => [@local_private_key_path],
                   :auth_methods => [auth_method],
                   :verbose => :info) do |ssh|
      SshExec.ssh_exec!(ssh, command)
    end
  end
end

def run_command_over_winrm(command, port=5986)
  endpoint = "https://#{@machine.ipaddress}:#{port}/wsman"
  winrm = WinRM::WinRMWebService.new(
    endpoint,
    :ssl,
    user: @config[:optional][:user],
    pass: @config[:optional][:password],
    disable_sspi: true,
  )
  with_retries(:max_tries => 5) do
    winrm.cmd(command)
  end
end

def puppet_resource_should_show(property_name, value=nil)
  it "should report the correct #{property_name} value" do
    # this overloading allows for passing either a key or a key and value
    # and naively picks the key from @config if it exists. This is because
    # @config is only available in the context of a test, and not in the context
    # of describe or context
    real_value = @config[:optional][property_name.to_sym] || value
    regex = if real_value.nil?
              /(#{property_name})(\s*)(=>)(\s*)/
            else
              /(#{property_name})(\s*)(=>)(\s*)('#{real_value}'|#{real_value})/i
            end
    expect(@result.stdout).to match(regex)
  end
end

def beaker_opts
  azure_cert = is_windows? ? WINDOWS_DOS_FORMAT_AZURE_CERT : LINUX_AZURE_CERT
  @env ||= {
      debug: true,
      trace: true,
      environment: {
        'AZURE_CLIENT_ID' => ENV['AZURE_CLIENT_ID'],
        'AZURE_CLIENT_SECRET' => ENV['AZURE_CLIENT_SECRET'],
        'AZURE_MANAGEMENT_CERTIFICATE' => azure_cert,
        'AZURE_SUBSCRIPTION_ID' => ENV['AZURE_SUBSCRIPTION_ID'],
        'AZURE_TENANT_ID' => ENV['AZURE_TENANT_ID'],
      }
    }
end

def is_windows?(host = nil)
  if host
    host['platform'] =~ /^windows/
  elsif defined?(default)
    # since `default` is from the beaker DSL, it is not accessible in `local` TESTMODE
    default['platform'] =~ /^windows/
  else
    # to support running the tests on windows in local TESTMODE,
    # add proper platform detection here.
    false
  end
end
