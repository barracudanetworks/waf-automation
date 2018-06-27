cudawaf_service  { 'DemoService2':
  ensure            => present,
  name              => 'MyService2',
  type              => 'HTTP',
  ip_address        => '10.11.2.2',
  port              => 8000,
  group             => 'default',
  vsite             => 'default',
  status            => 'On',
  address_version   => 'IPv4',
  comments          => 'Demo service',
}
 
cudawaf_cloudcontrol  {  'CloudControl':
  ensure            => present,
  state             => 'not_connected',
  connect_mode      => 'cloud',
  username          => 'user@domain.com',
  password          => 'password'
}
 
cudawaf_rule_group {  'RuleGroup-1':
  ensure            => present,
  name              => 'ContentRule1',
  service_name      => 'MyService2',
  url_match         => '/testing.html',
  host_match        => 'www.example.com'
}
 
cudawaf_rule_group_server  { 'RuleGroupServer-1':
  ensure        => absent,
  name          => 'rgServer1',
  service_name  => 'MyService2',
  rule_group_name => 'ContentRule1',
  identifier    => 'Hostname',
  hostname      => 'barracuda.com'
}
