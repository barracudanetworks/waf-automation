#
# Examples.ps1
#

$dev_name = "yourwafiporfqdn"
$dev_port = "8443"
$username = "admin"
$password = "yourpasswordhere"
$debug=1

#Authorisation to API
$authorisation = Login-BarracudaWAF -device $dev_name -username $username -password $password -device_port $dev_port -api_version 3 -UseSelfSignedCert -IsHTTPS

#Example that Gets the details of all WAF services

$answer = Get-BarracudaWAFService -device $dev_name -device_port $dev_port -token $authorisation -IsHTTPS -UseSelfSignedCert 

#Iterate through all the services supplied and print out selected properties.
foreach( $property in $answer.psobject.properties.name )
{
    $property
    $answer.$property.status
    $answer.$property.port
}


#Creates a new service
New-BarracudaWAFService -device $dev_name -device_port $dev_port -token $authorisation -name bobtwo -port 90 -type HTTP -service_ipaddress 10.2.0.10 -service_mask 255.255.255.0  -IsHTTPS -UseSelfSignedCert 

#Adds a server to a service
New-BarracudaWAFServer -device $dev_name -device_port $dev_port -token $authorisation -servicename bobtwo -name "Server1" -port 80 -ipaddress "10.2.0.25" -status 'In Service'  -IsHTTPS -UseSelfSignedCert 

(Get-BarracudaWAFWANIP -device $dev_name -token $authorisation -device_port $dev_port -IsHTTPS -UseSelfSignedCert ).'ip-address' 

#Put security policy active
Set-BarracudaWAFServiceSecurity -device $dev_name -token $authorisation -servicename bobtwo -mode Active -IsHTTPS -UseSelfSignedCert  -webfirewallpolicy default



Logout-BarracudaWAF -device $dev_name -device_port $dev_port -authentication $authorisation -IsHTTPS -UseSelfSignedCert 
