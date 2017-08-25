require 'stringio'
require 'puppet_x/puppetlabs/azure/config'
require 'puppet_x/puppetlabs/azure/not_finished'

module PuppetX
  module Puppetlabs
    module Azure
      class LoggerAdapter
        def info(msg)
          Puppet.info("azure-sdk: " + msg)
        end

        def warn(msg)
          Puppet.warning("azure-sdk: " + msg)
        end

        def error(msg)
          Puppet.err("azure-sdk: " + msg)
        end
      end

      class ProviderBase < Puppet::Provider
        def self.read_only(*methods)
          methods.each do |method|
            define_method("#{method}=") do |v|
              fail "#{method} property is read-only once #{resource.type} created."
            end
          end
        end

        def self.config
          ::PuppetX::Puppetlabs::Azure::Config.new
        end

        def self.prefetch(resources)
          instances.each do |prov|
            if resource = resources[prov.name] # rubocop:disable Lint/AssignmentInCondition
              resource.provider = prov
            end
          end
        end

        def exists?
          Puppet.info("Checking if #{name} exists")
          @property_hash[:ensure] and @property_hash[:ensure] != :absent
        end

        def running?
          !stopped?
        end

        def stop
          Puppet.info("Stopping #{name}")
          stop_vm(machine)
          @property_hash[:ensure] = :stopped
        end

        def start
          Puppet.info("Starting #{name}")
          start_vm(machine)
          @property_hash[:ensure] = :running
        end

        def encode_custom_data(data)
          if data.nil?
            nil
          else
            # Azure won't execute scripts without providing a shebang line.
            # Puppet will allow multi-line strings to be passed to properties,
            # but it's purely formatting so the linebreaks don't come through in
            # the resource hash. This data munging allows for simple one liners
            # to be encoded in Puppet without the use of a template.
            data = if data.include?("\n")
                     data
                   else
                     "#!/bin/bash\n#{data}"
                   end
            Base64.encode64(data).chomp
          end
        end

        private
        def machine
          object(:vm)
        end
        def resource_group
          object(:resource_group)
        end
        def storage_account
          object(:storage_account)
        end
        def object(type)
          obj = if @property_hash[:object]
                  @property_hash[:object]
                else
                  Puppet.debug("Looking up #{name}")
                  self.send("get_#{type}", name)
                end
          raise Puppet::Error, "No #{type} called #{name}" unless obj
          obj
        end
      end
    end
  end
end
