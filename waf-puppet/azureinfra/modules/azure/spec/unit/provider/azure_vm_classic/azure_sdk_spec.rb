require 'spec_helper'

provider_class = Puppet::Type.type(:azure_vm_classic).provider(:azure_sdk)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:azure_vm_classic).new(
      name: 'name',
      location: 'West US',
    )
  end

  let(:provider) { resource.provider }

  it 'should be an instance of the correct provider' do
    expect(provider).to be_an_instance_of Puppet::Type::Azure_vm_classic::ProviderAzure_sdk
  end

  [:vm_manager, :list_vms, :read_only, :machine_to_hash, :prefetch].each do |method|
    it "should respond to the class method #{method}" do
      expect(provider_class).to respond_to(method)
    end
  end

  [:exists?, :create, :destroy, :running?, :stopped?, :start, :stop].each do |method|
    it "should respond to the instance method #{method}" do
      expect(provider_class.new).to respond_to(method)
    end
  end

  it 'should have a prefetch which triggers a call to instances' do
    expect(provider_class).to receive(:instances).and_return([])
    provider_class.prefetch({})
  end

  describe 'creating a vm with custom_data' do
    context 'when set to a single-line string' do
      pending 'calls create_vm with a base64 encoded bash script'
    end

    context 'when set to a multi-line string' do
      pending 'calls create_vm with the base64 encoded value'
    end
  end
end
