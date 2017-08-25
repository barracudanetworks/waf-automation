require 'spec_helper_acceptance'

describe 'azure_vm_classic when creating a new machine in a stopped state' do
  include_context 'with certificate copied to system under test'
  include_context 'with a known name and storage account name'

  before(:all) do
    @config = {
      name: @name,
      ensure: 'stopped',
      optional: {
        image: UBUNTU_IMAGE,
        location: CHEAPEST_CLASSIC_LOCATION,
        user: 'specuser',
        private_key_file: @remote_private_key_path,
        storage_account: @storage_account_name, # required in order to tidy up created storage groups
      }
    }
    @manifest = PuppetManifest.new(@template, @config)
    @result = @manifest.execute
    @machine = @client.get_virtual_machine(@name).first
  end

  it_behaves_like 'an idempotent resource'

  include_context 'destroy left-over created resources after use'

  it 'should be stopped' do
    expect(@machine.status).to eq('StoppedDeallocated')
  end
end
