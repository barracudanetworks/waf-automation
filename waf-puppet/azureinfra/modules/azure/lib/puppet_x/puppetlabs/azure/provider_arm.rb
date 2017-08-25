require 'stringio'
require 'puppet_x/puppetlabs/azure/config'
require 'puppet_x/puppetlabs/azure/not_finished'
require 'puppet_x/puppetlabs/azure/provider_base'

require 'azure_mgmt_compute'
require 'azure_mgmt_resources'
require 'azure_mgmt_storage'
require 'azure_mgmt_network'
require 'ms_rest_azure'

module PuppetX
  module Puppetlabs
    module Azure
      # Azure Resource Management API
      #
      # The ARM API requires
      # subscription_id
      # tenant_id => Found in the URI of the portal along with the client subscrition_id
      # client_id => A application must be created on the default account ActiveDirectory for this to be created
      # client_secret => This is generated on the application created on the default account as well, once its saved.
      #
      # The application MUST be granted at least a contributor role for the ARM API to allow you access. This is done through
      # windows powershell.
      class ProviderArm < ::PuppetX::Puppetlabs::Azure::ProviderBase
        # Class Methods
        def self.credentials
          token_provider = ::MsRestAzure::ApplicationTokenProvider.new(ProviderBase.config.tenant_id,
            ProviderBase.config.client_id, ProviderBase.config.client_secret)

          ::MsRest::TokenCredentials.new(token_provider)
        end

        def self.with_subscription_id(client)
          client.subscription_id = ProviderBase.config.subscription_id
          client
        end

        def self.compute_client
          @compute_client ||= ProviderArm.with_subscription_id ::Azure::ARM::Compute::ComputeManagementClient.new(ProviderArm.credentials)
        end

        def self.network_client
          @network_client ||= ProviderArm.with_subscription_id ::Azure::ARM::Network::NetworkManagementClient.new(ProviderArm.credentials)
        end

        def self.storage_client
         @storage_client ||= ProviderArm.with_subscription_id ::Azure::ARM::Storage::StorageManagementClient.new(ProviderArm.credentials)
        end

        def self.resource_client
          @resource_client ||= ProviderArm.with_subscription_id ::Azure::ARM::Resources::ResourceManagementClient.new(ProviderArm.credentials)
        end

        # Public instance methods
        def create_vm(args) # rubocop:disable Metrics/AbcSize
          begin
            register_providers
            create_resource_group(args)
            create_storage_account({
              storage_account: args[:storage_account],
              resource_group: args[:resource_group],
              storage_account_type: args[:storage_account_type],
              location: args[:location],
            })
            params = build_params(args)
            ProviderArm.compute_client.virtual_machines.create_or_update(args[:resource_group], args[:name], params).value!.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def update_vm_storage_profile(args) # rubocop:disable Metrics/AbcSize
          params = build(::Azure::ARM::Compute::Models::VirtualMachine, {
            type: 'Microsoft.Compute/virtualMachines',
            location: args[:location],
            properties: build(::Azure::ARM::Compute::Models::VirtualMachineProperties, {
              storage_profile: build(::Azure::ARM::Compute::Models::StorageProfile, {
                data_disks: build_data_disks(args),
              })
            })
          })
          ProviderArm.compute_client.virtual_machines.create_or_update(args[:resource_group], args[:vm_name], params).value!.body
        rescue MsRest::DeserializationError => err
          raise Puppet::Error, err.response_body
        rescue MsRest::RestError => err
          raise Puppet::Error, err.to_s
        end

        def delete_vm(machine)
          begin
            ProviderArm.compute_client.virtual_machines.delete(resource_group, machine.name).value!.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def stop_vm(machine)
          begin
            ProviderArm.compute_client.virtual_machines.power_off(resource_group, machine.name).value!.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def start_vm(machine)
          begin
            ProviderArm.compute_client.virtual_machines.start(resource_group, machine.name).value!.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def get_all_sas
          begin
            sas = ProviderArm.storage_client.storage_accounts.list.value
            sas.collect do |sa|
              ProviderArm.storage_client.storage_accounts.get_properties(resource_group_from(sa), sa.name)
            end
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def get_all_deployments
          deployments = []
          rgs = get_all_rgs.collect(&:name)
          rgs.each do |rg|
            any_deps = get_deployments(rg)
            deployments += any_deps if any_deps
          end
          deployments
        end

        def get_deployments(resource_group) # rubocop:disable Metrics/AbcSize
          begin
            deployments = []
            Puppet.debug "Getting deployments in resource group #{resource_group}"
            result = ProviderArm.resource_client.deployments.list(resource_group)
            deployments += result.value
            while ! result.next_link.nil? and ! result.next_link.empty? do
              result = ProviderArm.resource_client.deployments.list_next(result.next_link)
              deployments += result.value
            end
            deployments.collect do |deployment|
              d = ProviderArm.resource_client.deployments.get(resource_group_from(deployment), deployment.name)
              #export = ProviderArm.resource_client.deployments.export_template(resource_group_from(deployment), deployment.name)
              #d.properties.template = export.template if export
              d
            end
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def get_all_rgs # rubocop:disable Metrics/AbcSize
          begin
            rgs = []
            result = ProviderArm.resource_client.resource_groups.list
            rgs += result.value
            while ! result.next_link.nil? and ! result.next_link.empty? do
              result = ProviderArm.resource_client.resource_groups.list_next(result.next_link)
              rgs += result.value
            end
            rgs.collect do |rg|
              ProviderArm.resource_client.resource_groups.get(rg.name)
            end
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def get_all_vms # rubocop:disable Metrics/AbcSize
          begin
            vms = []
            result = ProviderArm.compute_client.virtual_machines.list_all
            vms += result.value
            while ! result.next_link.nil? and ! result.next_link.empty? do
              result = ProviderArm.compute_client.virtual_machines.list_all_next(result.next_link)
              vms += result.value
            end
            vms.collect do |vm|
              ProviderArm.compute_client.virtual_machines.get(resource_group_from(vm), vm.name, 'instanceView')
            end
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def resource_group_from(machine)
          machine.id.split('/')[4].downcase
        end

        def get_vm(name)
          get_all_vms.find { |vm| vm.name == name }
        end

        # Private Methods
        private

        def register_providers
          register_azure_provider('Microsoft.Storage')
          register_azure_provider('Microsoft.Network')
          register_azure_provider('Microsoft.Compute')
        end

        def register_azure_provider(name)
          ProviderArm.resource_client.providers.register(name)
        end

        def create_resource_template(args) # rubocop:disable Metrics/AbcSize
          params = build_template_deployment(args)
          Puppet.debug("Validating template deployment and parameters")
          validation = ProviderArm.resource_client.deployments.validate(args[:resource_group], args[:template_deployment_name], params)
          if validation.error
            message = [validation.error.message]
            if validation.error.details
              deets = validation.error.details.collect(&:message)
              message << "Further information:"
              message += deets
            end
            fail message
          else
            ProviderArm.resource_client.deployments.create_or_update(args[:resource_group], args[:template_deployment_name], params).value!.body
          end
        end

        def delete_resource_template(rg, name)
          begin
            ProviderArm.resource_client.deployments.delete(rg, name).value!.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def create_resource_group(args)
          params = ::Azure::ARM::Resources::Models::ResourceGroup.new
          params.location = args[:location]
          ProviderArm.resource_client.resource_groups.create_or_update(args[:resource_group], params)
        end

        def delete_resource_group(rg)
          begin
            ProviderArm.resource_client.resource_groups.delete(rg.name).value!.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def create_storage_account(args)
          params = build_storage_account_create_parameters(args)
          ProviderArm.storage_client.storage_accounts.create(args[:resource_group], args[:storage_account], params).value!.body
        end

        def delete_storage_account(sa)
          begin
            ProviderArm.storage_client.storage_accounts.delete(resource_group, sa.name)
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def create_extension(args)
          params = build_virtual_machine_extensions(args)
          ProviderArm.compute_client.virtual_machine_extensions.create_or_update(args[:resource_group], args[:vm_name], args[:name], params).value!.body
        end

        def delete_extension(sa)
          begin
            ProviderArm.storage_client.storage_accounts.delete(resource_group, sa.name)
          rescue MsRest::HttpOperationError => err
            raise Puppet::Error, err.body
          rescue MsRest::DeserializationError => err
            raise Puppet::Error, err.response_body
          rescue MsRest::RestError => err
            raise Puppet::Error, err.to_s
          end
        end

        def create_virtual_network(args)
          params = build_virtual_network_params(args)
          ProviderArm.network_client.virtual_networks.create_or_update(args[:resource_group], args[:virtual_network_name], params).value!.body
        end

        def create_public_ip_address(args)
          params = build_public_ip_params(args)
          ProviderArm.network_client.public_ipaddresses.create_or_update(args[:resource_group], args[:public_ip_address_name], params).value!.body
        end

        def get_network_interface(resource_group, network_interface_name)
          ProviderArm.network_client.network_interfaces.get(resource_group, network_interface_name)
        end

        def get_public_ip_address(resource_group, public_ip_address_name)
          ProviderArm.network_client.public_ipaddresses.get(resource_group, public_ip_address_name)
        end

        def create_subnet(virtual_network, args)
          params = build_subnet_params(args)
          ProviderArm.network_client.subnets.create_or_update(
            args[:resource_group],
            virtual_network.name,
            args[:subnet_name],
            params
          ).value!.body
        end

        def create_network_interface(args, subnet)
          params = build_network_interface_param(args, subnet)
          ProviderArm.network_client.network_interfaces.create_or_update(args[:resource_group], params.name, params).value!.body
        end

        def build(klass, data={})
          model = klass.new
          data.each do |k,v|
            model.send "#{k}=", v
          end
          model
        end

        def build_os_vhd_uri(args)
          container = "https://#{args[:storage_account]}.blob.core.windows.net/#{args[:os_disk_vhd_container_name]}"
          "#{container}/#{args[:os_disk_vhd_name]}.vhd"
        end

        def build_image_reference(args) # rubocop:disable Metrics/AbcSize
          if ! args[:plan]
            publisher, offer, sku, version = args[:image].split(':')
          else
            publisher = args[:plan]['publisher']
            offer = args[:plan]['product']
            sku = args[:plan]['name']
            version = args[:plan]['version'] || 'latest'
          end
          build(::Azure::ARM::Compute::Models::ImageReference, {
            publisher: publisher,
            offer: offer,
            sku: sku,
            version: version,
          })
        end

        def build_template_deployment(args)
          build(::Azure::ARM::Resources::Models::Deployment, {
            properties: build_template_deployment_properties(args)
          })
        end

        def build_template_deployment_properties(args)
          build(::Azure::ARM::Resources::Models::DeploymentProperties, {
            template: args[:content],
            template_link: args[:source],
            parameters: args[:params],
            mode: 'Incremental', #design decision
          })
        end

        def build_storage_account_create_parameters(args)
          build(::Azure::ARM::Storage::Models::StorageAccountCreateParameters, {
            location: args[:location],
            kind: Object.const_get("::Azure::ARM::Storage::Models::Kind::#{args[:storage_account_kind] || :Storage}"),
            sku: build(::Azure::ARM::Storage::Models::Sku, {
              name: args[:storage_account_type],
            })
          })
        end

        def build_virtual_machine_extensions(args) # rubocop:disable Metrics/AbcSize
          props = if args[:properties].is_a?(Hash)
                    build(::Azure::ARM::Compute::Models::VirtualMachineExtensionProperties, {
                            'force_update_tag'           => args[:properties]['force_update_tag'],
                            'publisher'                  => args[:properties]['publisher'],
                            'type'                       => args[:properties]['type'],
                            'type_handler_version'       => args[:properties]['type_handler_version'],
                            'auto_upgrade_minor_version' => args[:properties]['auto_upgrade_minor_version'],
                            'settings'                   => args[:properties]['settings'],
                            'protected_settings'         => args[:properties]['protected_settings'],
                          })
                  end
          build(::Azure::ARM::Compute::Models::VirtualMachineExtension, {
            location: args[:location],
            name: args[:name],
            properties: props,
          })
        end

        def build_storage_profile(args)
          build(::Azure::ARM::Compute::Models::StorageProfile, {
            image_reference: build_image_reference(args),
            os_disk: build(::Azure::ARM::Compute::Models::OSDisk, {
              caching: args[:os_disk_caching],
              create_option: args[:os_disk_create_option],
              name: args[:os_disk_name],
              vhd: build(::Azure::ARM::Compute::Models::VirtualHardDisk, {
                uri: build_os_vhd_uri(args),
              })
            }),
            data_disks: build_data_disks(args),
          })
        end

        def build_data_disks(args)
          args[:data_disks].collect do |name,props|
            buildprops = {
              lun: props['lun'],
              name: name,
              disk_size_gb: props['disk_size_gb'],
              create_option: Object.const_get("::Azure::ARM::Compute::Models::DiskCreateOptionTypes::#{props['create_option']}"),
              vhd: build(::Azure::ARM::Compute::Models::VirtualHardDisk, {
                uri: props['vhd'],
              }),
            }
            if props['caching']
              buildprops[:caching] = Object.const_get("::Azure::ARM::Compute::Models::CachingTypes::#{props['caching']}")
            end
            build(::Azure::ARM::Compute::Models::DataDisk, buildprops)
          end unless args[:data_disks].nil?
        end

        def build_public_ip_params(args)
          build(::Azure::ARM::Network::Models::PublicIPAddress, {
            location: args[:location],
            properties: build(::Azure::ARM::Network::Models::PublicIPAddressPropertiesFormat, {
              public_ipallocation_method: args[:public_ip_allocation_method],
              dns_settings: build(::Azure::ARM::Network::Models::PublicIPAddressDnsSettings, {
                domain_name_label: args[:dns_domain_name],
              })
            })
          })
        end

        def build_virtual_network_params(args)
          build(::Azure::ARM::Network::Models::VirtualNetwork, {
            location: args[:location],
            properties: build(::Azure::ARM::Network::Models::VirtualNetworkPropertiesFormat, {
              address_space: build(::Azure::ARM::Network::Models::AddressSpace, {
                address_prefixes: [args[:virtual_network_address_space]],
              }),
              dhcp_options: build(::Azure::ARM::Network::Models::DhcpOptions, {
                dns_servers: args[:dns_servers].split,
              }),
              subnets: [build(::Azure::ARM::Network::Models::Subnet, {
                name: args[:subnet_name],
                properties: build(::Azure::ARM::Network::Models::SubnetPropertiesFormat, {
                  address_prefix: args[:subnet_address_prefix],
                })
              })]
            })
          })
        end

        def build_subnet_params(args)
          build(::Azure::ARM::Network::Models::Subnet, {
            properties: build(::Azure::ARM::Network::Models::SubnetPropertiesFormat, {
              address_prefix: args[:subnet_address_prefix],
            })
          })
        end

        def build_network_interface_param(args, subnet)
          network_interface_properties = {
            private_ipallocation_method: args[:private_ip_allocation_method],
            subnet: subnet,
          }
          if args[:public_ip_allocation_method] != 'None'
            network_interface_properties[:public_ipaddress] = create_public_ip_address(args)
          end
          build(::Azure::ARM::Network::Models::NetworkInterface, {
            location: args[:location],
            name: args[:network_interface_name],
            properties: build(::Azure::ARM::Network::Models::NetworkInterfacePropertiesFormat, {
              ip_configurations: [build(::Azure::ARM::Network::Models::NetworkInterfaceIPConfiguration, {
                name: args[:ip_configuration_name],
                properties: build(::Azure::ARM::Network::Models::NetworkInterfaceIPConfigurationPropertiesFormat, network_interface_properties),
              })],
            })
          })
        end

        def build_network_profile(args)
          build(::Azure::ARM::Compute::Models::NetworkProfile, {
            network_interfaces: [
              create_network_interface(
                args,
                create_subnet(create_virtual_network(args), args)
              )
            ]
          })
        end

        def build_plan(args)
          if args[:plan]
            build(::Azure::ARM::Compute::Models::Plan, {
              name: args[:plan]['name'],
              publisher: args[:plan]['publisher'],
              product: args[:plan]['product'],
              promotion_code: args[:plan]['promotion_code'],
            })
          end
        end

        def build_props(args)
          build(::Azure::ARM::Compute::Models::VirtualMachineProperties, {
            os_profile: build(::Azure::ARM::Compute::Models::OSProfile, {
              computer_name: args[:name],
              admin_username: args[:user],
              admin_password: args[:password],
              custom_data: args[:custom_data],
              secrets: [],
            }),
            hardware_profile: build(::Azure::ARM::Compute::Models::HardwareProfile, {
              vm_size: args[:size],
            }),
            storage_profile: build_storage_profile(args),
            network_profile: build_network_profile(args),
          })
        end

        def build_params(args)
          build(::Azure::ARM::Compute::Models::VirtualMachine, {
            type: 'Microsoft.Compute/virtualMachines',
            properties: build_props(args),
            plan: build_plan(args),
            location: args[:location],
          })
        end
      end
    end
  end
end
