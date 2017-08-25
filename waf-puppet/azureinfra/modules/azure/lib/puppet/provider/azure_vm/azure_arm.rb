require 'puppet_x/puppetlabs/azure/prefetch_error'
require 'puppet_x/puppetlabs/azure/provider_arm'

Puppet::Type.type(:azure_vm).provide(:azure_arm, :parent => PuppetX::Puppetlabs::Azure::ProviderArm) do
  confine feature: :azure
  confine feature: :azure_hocon
  confine feature: :azure_retries

  mk_resource_methods

  read_only(:image, :resource_group, :location, :size, :user, :os_disk_name,
            :os_disk_caching, :os_disk_create_option, :os_disk_vhd_container_name,
            :os_disk_vhd_name, :network_interface_name, :plan)

  def self.instances
    begin
      PuppetX::Puppetlabs::Azure::ProviderArm.new.get_all_vms.collect do |machine|
        hash = machine_to_hash(machine)
        Puppet.debug("Ignoring #{name} due to invalid or incomplete response from Azure") unless hash
        new(hash) if hash
      end.compact
    rescue Timeout::Error, StandardError => e
      raise PuppetX::Puppetlabs::Azure::PrefetchError.new(self.resource_type.name.to_s, e)
    end
  end

  def self.build_image_from_reference(image_reference)
    "#{image_reference.publisher}:#{image_reference.offer}:#{image_reference.sku}:#{image_reference.version}"
  end

  def self.machine_to_hash(machine) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    stopped = machine.properties.instance_view.statuses.find { |s| s.code =~ /PowerState\/stopped/ }.nil?
    ensure_value = stopped ? :running : :stopped

    network_interface_name = unless machine.properties.network_profile.network_interfaces.empty?
      machine.properties.network_profile.network_interfaces.first.id.split('/').last
    end

    vhd_name, vhd_container_name = unless machine.properties.storage_profile.os_disk.vhd.nil?
      parts = machine.properties.storage_profile.os_disk.vhd.uri.split('/')
      [parts[-1].split('.').first, parts[-2]]
    end
    if machine.resources
      extensions = machine.resources.inject(Hash.new) do |memo,res|
        memo[res.name] = {
          'auto_upgrade_minor_version' => res.properties.auto_upgrade_minor_version,
          'force_update_tag'           => res.properties.force_update_tag,
          'publisher'                  => res.properties.publisher,
          'type'                       => res.properties.type,
          'type_handler_version'       => res.properties.type_handler_version,
          'settings'                   => res.properties.settings,
          'protected_settings'         => res.properties.protected_settings,
          'provisioning_state'         => res.properties.provisioning_state, #read-only
        }
        memo
      end
    end
    if machine.properties.storage_profile.data_disks
      data_disks = machine.properties.storage_profile.data_disks.each_with_object(Hash.new) do |disk,memo|
        memo[disk.name] = {
          'lun'           => disk.lun,
          'caching'       => disk.caching,
          'disk_size_gb'  => disk.disk_size_gb,
          'create_option' => disk.create_option,
        }
        memo[disk.name]['vhd'] = disk.vhd.uri if disk.vhd
      end
    end
    if machine.plan
      plan = {
        'name'           => machine.plan.name,
        'product'        => machine.plan.product,
        'publisher'      => machine.plan.publisher,
      }
      plan['promotion_code'] = machine.plan.promotion_code if machine.plan.promotion_code
    end

    {
      name: machine.name,
      ensure: ensure_value,
      image: build_image_from_reference(machine.properties.storage_profile.image_reference),
      resource_group: machine.id.split('/')[4].downcase,
      location: machine.location,
      size: machine.properties.hardware_profile.vm_size,
      user: machine.properties.os_profile.admin_username,
      os_disk_name: machine.properties.storage_profile.os_disk.name,
      os_disk_caching: machine.properties.storage_profile.os_disk.caching,
      os_disk_create_option: machine.properties.storage_profile.os_disk.create_option,
      os_disk_vhd_container_name: vhd_container_name,
      os_disk_vhd_name: vhd_name,
      network_interface_name: network_interface_name,
      plan: plan,
      extensions: extensions,
      data_disks: data_disks,
      object: machine,
    }
  end

  def default_to_name(value)
    value || resource[:name]
  end

  def default_to_resource_group(value)
    value || resource[:resource_group]
  end

  def default_to_simple_name(value)
    value || resource[:name].downcase.gsub(/[^0-9a-z ]/i, '')
  end

  def default_based_on_name(value)
    value || resource[:name].downcase.gsub(/[^0-9a-z ]/i, '') + rand(999).to_s
  end

  def default_based_on_resource_group(value)
    value || resource[:resource_group].downcase.gsub(/[^0-9a-z ]/i, '') + rand(9999).to_s
  end

  def create # rubocop:disable Metrics/AbcSize
    Puppet.info("Creating #{resource[:name]}")
    create_vm({
      # required
      name: resource[:name],
      image: resource[:image],
      location: resource[:location],
      size: resource[:size],
      user: resource[:user],
      password: resource[:password],
      resource_group: resource[:resource_group],
      # type defaults
      storage_account_type: resource[:storage_account_type],
      os_disk_caching: resource[:os_disk_caching],
      os_disk_create_option: resource[:os_disk_create_option],
      os_disk_vhd_container_name: resource[:os_disk_vhd_container_name],
      dns_servers: resource[:dns_servers],
      public_ip_allocation_method: resource[:public_ip_allocation_method],
      virtual_network_address_space: resource[:virtual_network_address_space],
      subnet_name: resource[:subnet_name],
      subnet_address_prefix: resource[:subnet_address_prefix],
      private_ip_allocation_method: resource[:private_ip_allocation_method],
      data_disks: resource[:data_disks],
      plan: resource[:plan],
      # provider defaults recreate the defaults from the Azure Portal
      storage_account: default_based_on_resource_group(resource[:storage_account]),
      os_disk_name: default_to_name(resource[:os_disk_name]),
      os_disk_vhd_name: default_to_name(resource[:os_disk_vhd_name]),
      custom_data: encode_custom_data(resource[:custom_data]),
      dns_domain_name: default_to_simple_name(resource[:dns_domain_name]),
      public_ip_address_name: default_to_name(resource[:public_ip_address_name]),
      virtual_network_name: default_to_resource_group(resource[:virtual_network_name]),
      ip_configuration_name: default_to_name(resource[:ip_configuration_name]),
      network_interface_name: default_based_on_name(resource[:network_interface_name]),
    })

    self.extensions = resource[:extensions] if resource[:extensions]
  end

  def extensions=(value) # rubocop:disable Metrics/AbcSize
    value.each do |name, properties|
      Puppet.debug("Updating extension #{name} on vm #{resource[:name]}")

      if properties.is_a?(Hash)
        create_extension({
          :resource_group => resource[:resource_group],
          :location       => resource[:location],
          :vm_name        => resource[:name],
          :name           => name,
          :properties     => properties,
        })
      elsif properties == "absent"
        delete_extension({
          :resource_group => resource[:resource_group],
          :location       => resource[:location],
          :vm_name        => resource[:name],
          :name           => name,
        })
      else
        fail %{Expected extension properties to be a hash or "absent" but it was #{properties.inspect}}
      end
    end
  end

  def data_disks=(value)
    Puppet.debug("Updating data disks #{value.keys.join(', ')} on vm #{resource[:name]}")
    update_vm_storage_profile({
      :resource_group => resource[:resource_group],
      :location       => resource[:location],
      :vm_name        => resource[:name],
      :data_disks     => value,
    })
  end

  def destroy
    Puppet.info("Deleting #{name}")
    delete_vm(machine)
    @property_hash[:ensure] = :absent
  end

  def stopped?
    ! machine.properties.instance_view.statuses.find { |s| s.code =~ /PowerState\/stopped/ }.nil?
  end
end
