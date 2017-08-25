shared_context 'destroy left-over created resources after use' do
  after(:all) do
    # Some tests remove the VM themselves. This check avoids a error message in that case
    unless @client.get_virtual_machine(@machine.vm_name).empty?
      @client.destroy_virtual_machine(@machine)
      (@machine.data_disks.map { |h| h[:name] } + [ @machine.disk_name ]).each do |disk_name|
        @client.destroy_disk(disk_name)
      end
    end
    @client.destroy_storage_account(@storage_account_name) if @client.get_storage_account(@storage_account_name)
  end
end

shared_context 'destroy left-over created ARM resources after use' do
  after(:all) do
    # Some tests remove the VM themselves. This check avoids a error message in that case
    @client.destroy_vm(@machine) unless @client.get_vm(@machine).nil?
    @client.destroy_resource_group(
      @config[:optional][:resource_group]
    ) if @client.get_resource_group(@config[:optional][:resource_group])
    @client.destroy_storage_account(
      @config[:optional][:resource_group],
      @config[:optional][:storage_account]
    ) if @client.get_storage_account(@config[:optional][:storage_account])
  end
end
