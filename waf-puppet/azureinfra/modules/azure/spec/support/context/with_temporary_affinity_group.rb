shared_context 'with temporary affinity group' do
  before(:all) do
    @affinity_group_name = "CLOUD-AG-#{SecureRandom.hex(8)}"
    @client.create_affinity_group(@affinity_group_name)
  end
  after(:all) do
    @client.destroy_affinity_group(@affinity_group_name)
  end
end
