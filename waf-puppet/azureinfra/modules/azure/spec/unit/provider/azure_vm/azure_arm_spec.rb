require 'spec_helper'

provider_class = Puppet::Type.type(:azure_vm).provider(:azure_arm)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:azure_vm).new(
      name: 'spectestvm',
      location: 'eastus',
      size: 'Standard_A0',
      image: 'canonical:ubuntuserver:14.04.2-LTS:latest',
      password: 'Pa55wd!',
      user: 'specuser',
      resource_group: 'puppetresaccountazure',
      storage_account: 'puppetstorageaccount',
      storage_account_type: 'Standard_GRS',
      os_disk_name: 'osdisk01',
      os_disk_caching: 'ReadWrite',
      os_disk_create_option: 'FromImage',
      os_disk_vhd_container_name: 'conttest1',
      os_disk_vhd_name: 'vhdtest1',
      dns_domain_name: 'mydomain01',
      dns_servers: '10.1.1.1 10.1.2.4',
      public_ip_allocation_method: 'Dynamic',
      public_ip_address_name: 'ip_nametest01pubip',
      virtual_network_name: 'vnettest01',
      virtual_network_address_space: '10.0.0.0/16',
      subnet_name: 'subnet111',
      subnet_address_prefix: '10.0.2.0/24',
      ip_configuration_name: 'ip_config_test01',
      private_ip_allocation_method: 'Dynamic',
      network_interface_name: 'nicspec01',
    )
  end

  let(:provider) { resource.provider }

  it 'should be an instance of the correct provider' do
    expect(provider).to be_an_instance_of Puppet::Type::Azure_vm::ProviderAzure_arm
  end

  [:compute_client, :resource_client, :read_only, :storage_client, :network_client].each do |method|
    it "should respond to the class method #{method}" do
      expect(provider_class).to respond_to(method)
    end
  end

  [:exists?, :create, :destroy, :running?, :stopped?, :start, :stop].each do |method|
    it "should respond to the instance method #{method}" do
      expect(provider_class.new).to respond_to(method)
    end
  end
end
