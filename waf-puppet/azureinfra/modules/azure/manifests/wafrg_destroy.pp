class azure::wafrg_destroy {
azure_resource_template { 'lamp-test-ara':
  ensure         => 'absent',
  resource_group => 'testararg',
  content        => file('azure/ubuntu.template'),
  params         => {
    'adminPassword'          => '1234567a!',
    'addressPrefix'          => '10.0.0.0/16',
    'subnetPrefix'           => '10.0.0.0/24',
    'vmSize'                 => 'Standard_D2',
    'location'               => 'South Central US',
    'vmName'                 => 'lamp-test-ara',
    'storageAccountName'     => 'lamppuppet',
    'storageAccountType'     => 'Standard_RAGRS',
    'publicIPAddressName'    => 'Ara-lamp-ip',
    'dnsNameForIP'           => 'lamppublicpuppet',
    'vNETName'               => 'ara-prod',
    'subnetName'             => 'default',

        },
}
}
