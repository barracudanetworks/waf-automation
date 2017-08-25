azure_resource_group { 'testararg':
  ensure   => present,
  location => 'southcentralus',
}
# Example with a source
azure_resource_template { 'test-storage-account':
  ensure         => 'present',
  resource_group => 'test-rg',
  source         => 'https://gallery.azure.com/artifact/20151001/Microsoft.StorageAccount-ARM.1.0.1/DeploymentTemplates/StorageAccount.json',
  params         => {
    'accountType'       => 'Standard_RAGRS',
    'enableDiagnostics' => true,
    'location'          => 'southcentralus',
    'metricsLevel'      => 'ServiceAndApi',
    'metricsRetention'  => 'P7D',
    'name'              => 'arapuppet',
  },
}
# Example from https://github.com/Azure/azure-quickstart-templates/tree/master/101-loadbalancer-with-nat-rule
azure_resource_template { 'waf-test-template':
  ensure         => 'present',
  resource_group => 'testararg',
  content        => file('wafpayg.template'),
  params         => {
    'dnsNameForIP'        => 'stuffandthings02',
    'publicIPAddressType' => 'Dynamic',
    'addressPrefix'       => '10.0.0.0/16',
    'subnetPrefix'        => '10.0.0.0/24',
    'vmSize'		  => 'Standard_D2',
    'location'		  => 'South Central US',
    'vmName'		  => 'waf-test-ara',
    'storageAccountName'  => 'arapuppet',
    'storageAccountType'  => 'Standard_RAGRS',
    'publicIPAddressName' => 'Ara-WAF-ip',
    'dnsNameForIP'        => 'wafpublicpuppet',
    'subnetName'          => 'default',
  },
}
