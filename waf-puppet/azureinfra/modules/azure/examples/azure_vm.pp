azure_vm { 'testvm':
  ensure         => running,
  image          => 'canonical:ubuntuserver:14.04.2-LTS:latest',
  location       => 'eastus',
  user           => 'sampleuser',
  password       => 'SpecPass123!@#$%',
  size           => 'Standard_A0',
  resource_group => 'group',
}
