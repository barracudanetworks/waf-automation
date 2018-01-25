class azureprofiles::azure_rg {
azure_resource_group { 'testararg':
 ensure   => present,
  location => 'southcentralus',
}
}
