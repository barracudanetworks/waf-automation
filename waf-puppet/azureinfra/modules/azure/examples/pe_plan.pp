azure_vm { 'puppetmaster':
  ensure         => 'running',
  location       => 'westus',
  resource_group => 'hunner-plan',
  size           => 'Standard_A0',
  user           => 'hunner',
  password       => '1N53cure!',
  plan           => {
    'name'      => '2016-1',
    'product'   => 'puppet-enterprise',
    'publisher' => 'puppet',
  },
}
