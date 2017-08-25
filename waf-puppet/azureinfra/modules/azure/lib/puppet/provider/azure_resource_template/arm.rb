require 'puppet_x/puppetlabs/azure/prefetch_error'
require 'puppet_x/puppetlabs/azure/provider_arm'
require 'puppet/util/filetype'

Puppet::Type.type(:azure_resource_template).provide(:arm, :parent => PuppetX::Puppetlabs::Azure::ProviderArm) do
  confine feature: :azure
  confine feature: :azure_hocon
  confine feature: :azure_retries

  mk_resource_methods

  def self.instances # rubocop:disable Metrics/AbcSize
    begin
      PuppetX::Puppetlabs::Azure::ProviderArm.new.get_all_deployments.collect do |dep|
        params = dep.properties.parameters.each_with_object({}) do |(k,v),memo|
          memo[k] = v['value']
        end

        hash = {
          name: dep.name,
          ensure: :present,
          resource_group: dep.id.split('/')[4],
          content: dep.properties.template,
          params: params,
          object: dep,
        }
        if hash
          if dep.properties.template_link
            hash[:source] = dep.properties.template_link.uri
          end
          new(hash) if hash
        end
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
    @property_hash[:ensure] = :present
  end

  def destroy
    delete_resource_template(@property_hash[:resource_group], @property_hash[:name])
    @property_hash[:ensure] = :absent
  end

  def flush
    if @property_hash[:ensure] != :absent
      create_resource_template(create_hash)
    end
  end

  def create_hash # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity
    hash = {
      template_deployment_name: resource[:name],
      resource_group: resource[:resource_group],
    }

    content = read_content
    params = read_params
    if content
      hash[:content] = if content.is_a?(String)
                         JSON.parse(content)
                       else
                         content
                       end
    else
      hash[:source] = resource[:source]
    end
    if params
      hash[:params] = if params.is_a?(String)
                        JSON.parse(params)
                      else
                        params.each_with_object({}) do |(k,v),memo|
                          memo[k] = { 'value' => v }
                        end
                      end
    else
      hash[:params_source] = resource[:params_source]
    end
    hash
  end

  def read_content
    if resource[:source]
      if resource[:source] !~ %r{^(puppet|https?)://}
        text = Puppet::Util::FileType.filetype(:flat).new(resource[:source]).read
        if text
          return text
        else
          fail "source appears to be a local path but does not exist: #{source}"
        end
      end
    else
      resource[:content]
    end
  end

  def read_params
    if resource[:params_source]
      if resource[:params_source] !~ %r{^(puppet|https?)://}
        text = Puppet::Util::FileType.filetype(:flat).new(resource[:params_source]).read
        if text
          return text
        else
          fail "params_source appears to be a local path but does not exist: #{params_source}"
        end
      end
    else
      resource[:params]
    end
  end
end
