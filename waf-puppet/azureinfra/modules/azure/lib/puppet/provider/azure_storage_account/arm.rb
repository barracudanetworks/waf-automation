require 'puppet_x/puppetlabs/azure/prefetch_error'
require 'puppet_x/puppetlabs/azure/provider_arm'

Puppet::Type.type(:azure_storage_account).provide(:arm, :parent => PuppetX::Puppetlabs::Azure::ProviderArm) do
  confine feature: :azure
  confine feature: :azure_hocon
  confine feature: :azure_retries

  mk_resource_methods

  read_only(:location, :resource_group, :account_kind, :account_type)

  def self.instances # rubocop:disable Metrics/AbcSize
    begin
      PuppetX::Puppetlabs::Azure::ProviderArm.new.get_all_sas.collect do |sa|
        hash = {
          name: sa.name,
          ensure: :present,
          location: sa.location,
          account_type: sa.sku.name,
          account_kind: sa.kind,
          resource_group: sa.id.split('/')[4],
          object: sa,
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
    create_storage_account({
      storage_account: resource[:name],
      resource_group: resource[:resource_group],
      storage_account_type: resource[:account_type],
      storage_account_kind: resource[:account_kind],
      location: resource[:location],
    })
    @property_hash[:ensure] = :present
  end

  def destroy
    delete_storage_account(storage_account)
    @property_hash[:ensure] = :absent
  end
end
