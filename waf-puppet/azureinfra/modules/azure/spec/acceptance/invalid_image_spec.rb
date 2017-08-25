require 'spec_helper_acceptance'

describe 'azure_vm_classic when providing an invalid image' do
  include_context 'with certificate copied to system under test'

  before(:all) do
    @name = "CLOUD-#{SecureRandom.hex(8)}"
    config = {
      name: @name,
      ensure: 'present',
      optional: {
        location: CHEAPEST_CLASSIC_LOCATION,
        image: 'INVALID_IMAGE_NAME',
      }
    }
    @result = PuppetManifest.new(@template, config).execute
  end

  it 'reports errors from the API' do
    expect(@result.output).to match /Failed to create virtual machine.*:.*The virtual machine image source is not valid\./
  end

  it 'reports the error in the exit code' do
    expect(@result.exit_code).to eq 4
  end
end
