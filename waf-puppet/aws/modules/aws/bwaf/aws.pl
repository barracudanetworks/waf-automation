##! /usr/bin/perl -w
use strict;
use Data::Dumper;
use JSON::XS;
use Exporter qw( import );
#create json decoder object
my $DECODER = new JSON::XS->allow_nonref(1);


my $PASSWORD = `sudo aws ec2 describe-instances --filters '{\"Name\":\"tag:tag_name\",\"Values\":[\"testinstance\"]}' --output=text --query 'Reservations[*].Instances[*].InstanceId'`;
print "id --> ($PASSWORD)\n";
$PASSWORD =~ s/(.*?)\s+(.*?)\s+(.*)/$1/;
chomp($PASSWORD);
print "id --> ($PASSWORD)\n";

chomp (my $publicip = `sudo aws ec2 describe-instances --filters '{\"Name\":\"tag:tag_name\",\"Values\":[\"testinstance\"]}' --output=text --query 'Reservations[*].Instances[*].PublicIpAddress'`);
print "ip --> ($publicip)\n";

#to check if the ec2 instance is running
#my $STATUS =  `sudo aws ec2 describe-instances --filters '{\"Name\":\"tag:tag_name\",\"Values\":[\"testinstance\"]}' --output=text | grep "running"| cut -c 10-16

#log into waf
my $ret = `curl http://$publicip:8000/restapi/v1/login -X POST -H Content-Type:application/json -d '{"username": "admin", "password": "$PASSWORD" }'`;
print "ret ---> (", Dumper($ret);
my $native_data = $DECODER->decode($ret);
print "native_ret ---> (", Dumper($native_data);
print "token ---> ($native_data->{'token'})\n";
my $TOKEN = $native_data->{'token'};

#create service 
#my $ret = `curl  http://10.11.31.231:8000/restapi/v1/virtual_services -u '$TOKEN:' -X POST -H Content-Type:application/json -d '{"name": "demo-1-service", "ip_address":"99.99.107.35", "port":"81", "type":"HTTP", "address_version":"ipv4", "vsite":"default", "group":"default"}'`;
my $ret = `curl  http://$publicip:8000/restapi/v1/virtual_services -u '$TOKEN:' -X POST -H Content-Type:application/json -d '{"name": "demo-1-service", "ip_address":"99.99.107.35", "port":"81", "type":"HTTP", "address_version":"ipv4", "vsite":"default", "group":"default"}'`;

print "ret ---> (", Dumper($ret);
my $native_data = $DECODER->decode($ret);
print "native_ret ---> (", Dumper($native_data);
