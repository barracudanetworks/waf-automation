#!/usr/bin/perl

use strict;

use Data::Dumper;
use warnings;

use JSON::XS qw(encode_json decode_json);

my $waf_ip   = $ARGV[0];
my $waf_port = $ARGV[1] || 8000; 
my $username = $ARGV[2];
my $password = $ARGV[3];
my $svr_ip   = $ARGV[4];
my $svr_port = $ARGV[5];
my $action   = $ARGV[6];

my $login_token = `curl http://$waf_ip:$waf_port/restapi/v3/login -X POST -H Content-Type:application/json -d '{"username":"$username","password":"$password"}'`;
my $token_str = decode_json($login_token);

if (!defined $token_str->{token} && defined $token_str->{errors}) {
    my $error_msg = $token_str->{errors}->{msg};
    my $error_type = $token_str->{errors}->{type};
    print "$error_type:$error_msg.\n";
    exit 0;
}

$token_str = Data::Dumper::qquote($token_str->{token});
$token_str =~ s/"//g;

print "Login Successful.\n";
print "Login token - ", $token_str, "\n";

my $result = `curl -s http://$waf_ip:$waf_port/restapi/v3/services?parameters=name -u '$token_str:' -X GET `;
$result = decode_json($result);
my $data_hash = $result->{data};
my @svc_arr = ();
for (keys %$data_hash){
     push(@svc_arr, $data_hash->{$_}->{name});
}

for (@svc_arr){
    my $result = `curl -s http://$waf_ip:$waf_port/restapi/v3/services/$_/servers?parameters=name,ip-address,port -u '$token_str:' -X GET `; 
    $result = decode_json($result);
    my $data = $result->{data};
    my $svc = $_;
#    print STDERR "***************** SERVER DETAILS FOR SERVICE $_ ****************\n\n";
    for (keys %$data){
 #        print STDERR "\nSERVER NAME => $data->{$_}->{name}"."\nSERVER IP => $data->{$_}->{'ip-address'} \n"."SERVER PORT => $data->{$_}->{port}\n";
         if ($data->{$_}->{'ip-address'} eq $svr_ip && $data->{$_}->{port} == $svr_port){
              remove_svr_from_svc($svc, $svr_ip, $svr_port, $data->{$_}->{'name'}); 
         }
    }
}

sub remove_svr_from_svc {
    my ($svc, $svr_ip, $svr_port, $svr_name) = @_;
    print STDERR "Making changes for server $svr_name ($svr_ip, $svr_port) in service $svc\nSetting server status as $action\n";
    my $result = `curl -s http://$waf_ip:$waf_port/restapi/v3/services/$svc/servers/$svr_name -u '$token_str:' -X PUT -H Content-Type:application/json -d '{"status":"$action"}'`;
    $result = decode_json($result);
    print STDERR $result->{msg}."\n\n";
}
