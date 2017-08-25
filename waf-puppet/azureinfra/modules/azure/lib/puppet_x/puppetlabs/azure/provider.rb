require 'stringio'
require 'puppet_x/puppetlabs/azure/config'
require 'puppet_x/puppetlabs/azure/not_finished'
require 'puppet_x/puppetlabs/azure/provider_base'

module PuppetX
  module Puppetlabs
    module Azure
      # Azure Classic API
      class Provider < ProviderBase
        # all of this needs to happen once in the life-time of the runtime,
        # but Puppet.feature does not allow us to add a feature-conditional
        # initialization, so we need to be a little bit circumspect here.
        begin
          require 'azure'
          require 'azure/core'
          ::Azure::Core::Logger.initialize_external_logger(LoggerAdapter.new)
        rescue LoadError
          Puppet.debug("Couldn't load azure SDK")
        end
        # Workaround https://github.com/Azure/azure-sdk-for-ruby/issues/269
        # This needs to be separate from the rescue above, as this might
        # get fixed on a different schedule.
        begin
          require 'azure/virtual_machine_image_management/virtual_machine_image_management_service'
        rescue LoadError
          Puppet.debug("Couldn't load azure SDK")
        end

        def self.auth(&client)
          unless @authenticated
            cert_file = self.config.management_certificate
            unless cert_file && File.file?(cert_file)
              raise Puppet::Error, "Azure management certificate does not exist [#{self.config.management_certificate}]. Please set AZURE_MANAGEMENT_CERTIFICATE environment variable, or management_certificate config entry to the full path."
            end
            Puppet.debug("Using management certificate at [#{self.config.management_certificate}]")
            ::Azure.subscription_id = self.config.subscription_id
            ::Azure.management_certificate = self.config.management_certificate
            @authenticated = true
          end
          yield client
        end

        def self.vm_manager
          @vm_manager ||= auth { ::Azure.vm_management }
        end

        def self.cloud_service_manager
          @cloud_service_manager ||= auth { ::Azure.cloud_service_management }
        end

        def self.disk_manager
          @disk_manager ||= auth { ::Azure.vm_disk_management }
        end

        def self.list_vms
          vm_manager.list_virtual_machines
        end

        def self.ensure_from(status)
          case status
          when 'StoppedDeallocated', 'Stopped'
            :stopped
          else
            :running
          end
        end

        def stopped?
          ['StoppedDeallocated', 'Stopped'].include? machine.status
        end

        def self.get_cloud_service(service_name)
          @services ||= Hash.new do |h, key|
            h[key] = cloud_service_manager.get_cloud_service(key) if key
          end
          @services[service_name]
        end

        def get_vm(name)
          Provider.vm_manager.list_virtual_machines.find { |x| x.vm_name == name }
        end

        def create_disk(vm_name, cloud_service_name, data_disk_size_gb)
          Provider.vm_manager.add_data_disk(
            vm_name,
            cloud_service_name,
            {
              disk_label: "data-disk-for-#{vm_name}",
              disk_size: data_disk_size_gb,
              import: false,
            }
          )
        end

        def adding_role?(cloud_service_name)
          add_role = false

          return false if cloud_service_name.nil?

          cloud_service = Provider.cloud_service_manager.get_cloud_service(cloud_service_name)
          return false if cloud_service.nil?

          begin
            service_properties = Provider.cloud_service_manager.get_cloud_service_properties(cloud_service_name)
            deployments = service_properties.virtual_machines

            add_role = deployments.count >= 1
          rescue Exception
            # This might lead to false negatives when the API or network is not well-behaved
            # Since it doesn't impact idempotency or data reliability, we punted this issue
            # until a general reliability overhaul of the azure SDK or our usage of it.
            add_role = false
          end

          add_role
        end

        def create_vm(args) # rubocop:disable Metrics/AbcSize
          cloud_service_name = args[:cloud_service_name]
          param_names = [:vm_name, :image, :location, :vm_user, :password, :custom_data]
          params = (args.keys & param_names).each_with_object({}) { |k,h| h.update(k=>args.delete(k)) }
          sanitised_params = params.delete_if { |k, v| v.nil? }
          sanitised_args = args.delete_if { |k, v| v.nil? }
          data_disk_size_gb = sanitised_args.delete(:data_disk_size_gb)

          if adding_role?(cloud_service_name)
            sanitised_params[:cloud_service_name] = cloud_service_name
            Provider.vm_manager.add_role(sanitised_params, sanitised_args)
          else
            Provider.vm_manager.create_virtual_machine(sanitised_params, sanitised_args)
          end
          if data_disk_size_gb
            create_disk(params[:vm_name], cloud_service_name, data_disk_size_gb)
          end
        end

        def delete_vm(machine)
          Provider.vm_manager.delete_virtual_machine(machine.vm_name, machine.cloud_service_name)
        end

        def delete_disk(disk_name) # rubocop:disable Metrics/AbcSize
          # Since the API does not guarantee the removal of the disk, we need to take
          # extra care to clean up. Additionally, when touching disks of VMs going out,
          # Azure sometimes has a lock on them, causing API calls to fail with API errors.
          with_retries(:max_tries => 10,
                       :base_sleep_seconds => 20,
                       :max_sleep_seconds => 20,
                       :rescue => [
                         NotFinished,
                         ::Azure::Core::Error,
                         # The following errors can occur when there are network issues
                         Errno::ECONNREFUSED,
                         Errno::ECONNRESET,
                         Errno::ETIMEDOUT,
                       ]) do
            Puppet.debug("Trying to deleting disk #{disk_name}")
            begin
              Provider.disk_manager.delete_virtual_machine_disk(disk_name)
              if Provider.disk_manager.get_virtual_machine_disk(disk_name)
                Puppet.debug("Disk was not deleted. Retrying to deleting disk #{disk_name}")
                raise NotFinished.new
              end
            rescue NotFinished
              raise
            rescue ::Azure::Core::Error
              raise
            rescue RuntimeError => err
              # The disk may already be in the process of being deleted by Azure,
              # therefore we might have lost that race
              # Note: pattern cannot be anchored, since the azure-sdk adds its own
              # escape sequences for coloring it
              case err.message
              when /ConflictError : Windows Azure is currently performing an operation/
                raise NotFinished.new
              when /ResourceNotFound : The disk with the specified name does not exist/
                return # it's gone!
              else
                raise
              end
            rescue => err
              # Sometimes azure throws weird ConflictErrors that do not seem to be
              # ::Azure::Core::Error . Of course as soon as I added these debugs
              # Azure stopped conflicting. I'll leave these in for now, to maybe
              # catch this later
              Puppet.info("Please report this - leaking disk #{disk_name}")
              Puppet.info("CAUGHT: class #{err.class}")
              Puppet.info("CAUGHT: inspc #{err.inspect}")
              Puppet.info("CAUGHT: to_s  #{err}")
              raise
            end
          end
          if Provider.disk_manager.get_virtual_machine_disk(disk_name)
            Puppet.warning("Disk #{disk_name} was not deleted")
          else
            Puppet.debug("Disk #{disk_name} was deleted")
          end
        end

        def update_endpoints(should) # rubocop:disable Metrics/AbcSize
          Puppet.debug("Updating endpoints for #{name}: from #{endpoints} to #{should.inspect}")
          unless endpoints == :absent
            to_delete = endpoints.collect { |ep| ep[:name] } - should.collect { |ep| ep[:name] }
            to_delete.each do |name|
              Provider.vm_manager.delete_endpoint(resource[:name], resource[:cloud_service], name)
            end
          end
          Provider.vm_manager.update_endpoints(resource[:name], resource[:cloud_service], should)
        end

        def stop_vm(machine)
          Provider.vm_manager.shutdown_virtual_machine(machine.vm_name, machine.cloud_service_name)
        end

        def start_vm(machine)
          Provider.vm_manager.start_virtual_machine(machine.vm_name, machine.cloud_service_name)
        end
      end
    end
  end
end
