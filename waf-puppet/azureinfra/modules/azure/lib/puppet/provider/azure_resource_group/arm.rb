require 'puppet_x/puppetlabs/azure/prefetch_error'
require 'puppet_x/puppetlabs/azure/provider_arm'

Puppet::Type.type(:azure_resource_group).provide(:arm, :parent => PuppetX::Puppetlabs::Azure::ProviderArm) do
  confine feature: :azure
  confine feature: :azure_hocon
  confine feature: :azure_retries

  mk_resource_methods

  read_only(:location)

  def self.instances # rubocop:disable Metrics/AbcSize
    begin
      PuppetX::Puppetlabs::Azure::ProviderArm.new.get_all_rgs.collect do |rg|
        hash = {
          name: rg.id.split('/')[4],
          ensure: :present,
          location: rg.location,
          object: rg,
        }
        Puppet.debug("Ignoring #{name} due to invalid or incomplete response from Azure") unless hash
        new(hash) if hash
      end.compact
    rescue Timeout::Error, StandardError => e
      raise PuppetX::Puppetlabs::Azure::PrefetchError.new(self.resource_type.name.to_s, e)
    end
  end

  # Allow differing case
  def self.prefetch(resources)
    instances.each do |prov|
      if resource = (resources.find { |k,v| k.casecmp(prov.name).zero? } || [])[1] # rubocop:disable Lint/AssignmentInCondition
        resource.provider = prov
      end
    end
  end

  def create
    create_resource_group({
      resource_group: resource[:name],
      location: resource[:location],
    })
    @property_hash[:ensure] = :present
  end

  def destroy
    delete_resource_group(resource_group)
    @property_hash[:ensure] = :absent
  end
end
