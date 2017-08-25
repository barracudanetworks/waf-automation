require 'spec_helper_acceptance'

context "when no management certificate is set while running 'puppet resource azure_vm_classic'" do
  include_context 'with certificate copied to system under test'

  before(:all) do
    opts = beaker_opts
    opts[:environment].delete('AZURE_MANAGEMENT_CERTIFICATE')
    # also remove the local value for BEAKER_TESTMODE=local
    old_cert = ENV.delete('AZURE_MANAGEMENT_CERTIFICATE')
    @result = resource('azure_vm_classic', 'foo', opts)
    ENV['AZURE_MANAGEMENT_CERTIFICATE'] = old_cert
  end

  it "should report an error pointing to missing ENV/config var" do
    expect(@result.stderr).to match(/AZURE_MANAGEMENT_CERTIFICATE/)
  end
end
