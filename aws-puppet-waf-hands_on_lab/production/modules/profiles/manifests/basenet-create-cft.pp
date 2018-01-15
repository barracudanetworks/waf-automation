cloudformation_stack { 'basenetprod':
  ensure        => updated,
  region        => hiera('region'),
  template_url  => hiera('basenet'),
}
