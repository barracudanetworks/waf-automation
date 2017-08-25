shared_context 'with a known name and storage account name' do
  before(:all) do
    # Windows machines can't have names longer than 15 characters
    @name = "CLOUD-#{SecureRandom.hex(4)}"
    @storage_account_name = "cloud#{SecureRandom.hex(8)}"
  end
end
