class azureprofiles::azure_storageaccount{

azure_resource_template { 'arapuppet':
  ensure         => 'present',
  resource_group => 'testararg',
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
}
