azure_resource_group { 'hunner':
  ensure   => present,
  location => 'westus',
}
azure_storage_account { 'slowspace':
  ensure         => present,
  location       => 'westus',
  account_type   => 'Standard_GRS',
  resource_group => 'hunner',
  before         => Azure_vm['candy'],
}
azure_storage_account { 'hunnerdisks861':
  ensure         => present,
  location       => 'westus',
  account_type   => 'Standard_GRS',
  resource_group => 'hunner',
  before         => Azure_vm['candy'],
}
azure_vm { 'candy':
  ensure                     => 'running',
  image                      => 'CoreOS:CoreOS:Stable:latest',
  location                   => 'westus',
  network_interface_name     => 'candy891',
  os_disk_caching            => 'ReadWrite',
  os_disk_create_option      => 'FromImage',
  os_disk_name               => 'candy',
  os_disk_vhd_container_name => 'vhds',
  os_disk_vhd_name           => 'candy2016726122234',
  resource_group             => 'hunner',
  size                       => 'Standard_DS1_v2',
  user                       => 'hunner',
  password                   => '1N53cure!',
  data_disks                 => {
    'some_name_here' => {
      'caching'       => 'ReadOnly',
      'create_option' => 'Empty',
      'disk_size_gb'  => '128',
      'lun'           => '0',
      'vhd'           => 'https://hunnerdisks861.blob.core.windows.net/vhds/some_name_here.vhd',
      },
      'another'      => {
        'caching'       => 'None',
        'create_option' => 'Empty',
        'disk_size_gb'  => '15',
        'lun'           => '1',
        'vhd'           => 'https://slowspace.blob.core.windows.net/wat/another.vhd',
      },
  },
}
