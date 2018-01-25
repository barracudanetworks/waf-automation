class azure {
azure_resource_template { 'waf-test-ara':
  ensure         => 'present',
  resource_group => 'testararg',
  content        => file('azure/wafpayg.template'),
  params         => {
    'adminPassword'	  => '1234567a!',
    'addressPrefix'       => '10.0.0.0/16',
    'subnetPrefix'        => '10.0.0.0/24',
    'vmSize'		  => 'Standard_D2',
    'location'		  => 'South Central US',
    'vmName'		  => 'waf-test-ara',
    'storageAccountName'  => 'arapuppet',
    'storageAccountType'  => 'Standard_RAGRS',
    'publicIPAddressName' => 'Ara-WAF-ip',
    'dnsNameForIP'        => 'wafpublicpuppet',
    'vNETName'		  => 'ara-prod',
    'subnetName'          => 'default',
  },
}

}
