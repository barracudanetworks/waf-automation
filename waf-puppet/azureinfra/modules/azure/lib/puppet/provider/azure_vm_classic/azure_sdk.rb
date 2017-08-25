require 'base64'

require 'puppet_x/puppetlabs/azure/prefetch_error'
require 'puppet_x/puppetlabs/azure/provider'


Puppet::Type.type(:azure_vm_classic).provide(:azure_sdk, :parent => PuppetX::Puppetlabs::Azure::Provider) do
  confine feature: :azure_classic
  confine feature: :azure_hocon
  confine feature: :azure_retries

  mk_resource_methods

  read_only(:location, :deployment, :image, :cloud_service, :size,
            :virtual_network, :subnet, :reserved_ip, :availability_set)

  def self.instances
    begin
      list_vms.collect do |machine|
        hash = machine_to_hash(machine)
        Puppet.debug("Ignoring #{name} due to invalid or incomplete response from Azure") unless hash
        new(hash) if hash
      end.compact
    rescue Timeout::Error, StandardError => e
      raise PuppetX::Puppetlabs::Azure::PrefetchError.new(self.resource_type.name.to_s, e)
    end
  end

  def self.data_disk_size_gb_from(machine)
    if machine.data_disks.empty?
      0
    else
      machine.data_disks.first[:size_in_gb]
    end
  end

  def self.endpoints_from_machine(machine)
    udp_endpoints = machine.udp_endpoints.collect do |udp|
      udp = udp.dup
      udp.delete(:vip)
      udp[:protocol] = 'udp'
      udp
    end
    tcp_endpoints = machine.tcp_endpoints.collect do |tcp|
      tcp = tcp.dup
      tcp.delete(:vip)
      tcp[:protocol] = 'tcp'
      tcp
    end
    udp_endpoints + tcp_endpoints
  end

  def self.machine_to_hash(machine) # rubocop:disable Metrics/AbcSize
    cloud_service = get_cloud_service(machine.cloud_service_name)
    location = cloud_service.location || cloud_service.extended_properties["ResourceLocation"]
    {
      name: machine.vm_name,
      image: machine.image,
      ensure: ensure_from(machine.status),
      location: location,
      deployment: machine.deployment_name,
      cloud_service: machine.cloud_service_name,
      os_type: machine.os_type,
      ipaddress: machine.ipaddress,
      hostname: machine.hostname,
      media_link: machine.media_link,
      size: machine.role_size,
      virtual_network: machine.virtual_network_name,
      subnet: machine.subnet,
      availability_set: machine.availability_set_name,
      cloud_service_object: cloud_service,
      data_disk_size_gb: data_disk_size_gb_from(machine),
      endpoints: endpoints_from_machine(machine),
      object: machine,
    }
  end

  def create # rubocop:disable Metrics/AbcSize
    Puppet.info("Creating #{name}")
    params = {
      vm_name: name,
      image: resource[:image],
      location: resource[:location],
      vm_size: resource[:size],
      vm_user: resource[:user],
      password: resource[:password],
      private_key_file: resource[:private_key_file],
      deployment_name: resource[:deployment],
      virtual_network_name: resource[:virtual_network],
      cloud_service_name: resource[:cloud_service],
      data_disk_size_gb: resource[:data_disk_size_gb],
      custom_data: encode_custom_data(resource[:custom_data]),
      storage_account_name: resource[:storage_account],
      subnet_name: resource[:subnet],
      reserved_ip_name: resource[:reserved_ip],
      availability_set_name: resource[:availability_set],
      affinity_group_name: resource[:affinity_group],
    }
    create_vm(params)
    update_endpoints(resource[:endpoints]) if resource[:endpoints] and !resource[:endpoints].empty?
  end

  def destroy # rubocop:disable Metrics/AbcSize
    Puppet.info("Deleting #{name}")
    delete_vm(machine)
    if resource[:purge_disk_on_delete]
      Puppet.info("Deleting disks for #{name}")
      delete_disk(machine.disk_name)
      machine.data_disks.each { |d| delete_disk(d[:name]) }
    end
    @property_hash[:ensure] = :absent
  end
 end
