shared_context 'with known network' do
  before(:all) do
    # Since the API does not provide for a way to remove networks, we re-use it across tests
    # See ensure_network for details.
    @virtual_network_name = "CLOUD-VNET-ACCEPTANCE"
    @client.ensure_network(@virtual_network_name)
    @network = @client.get_virtual_network(@virtual_network_name)
  end
end
