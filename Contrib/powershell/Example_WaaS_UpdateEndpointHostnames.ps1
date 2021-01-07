<#
This example script is used to update add additional hostnames to the endpoints of a WaaS Application. 


#>

#Imports the WaaS Module
Import-Module BarracudaWaaS -Force

#Adjust this to the path of list of domains to add.
$offlinesourcefile = "C:\Store\domainlist.csv"

<#The CSV is simply a list of domains, with each FQDN on a new line there is no header line. e.g
testdomain1.local
testdomain2.local
testdomain3.local
#>

$domainlistimport = Import-Csv -Path $offlinesourcefile -Delimiter "," -Header Domains

if($domainlistimport.Count -gt 100){
    Write-Error "To many domains, only 100 domains can be added to any service"
    throw
}
#Provide login credentials for WAF as a Service
$waas_creds = Get-Credential

#Login to WaaS / you may be prompted for MFA at this point. 
$waas_token = Login-BarracudaWaaS -credentials $waas_creds

#Print Available Apps
Get-BarracudaWaaS-Application -authkey $waas_token.key | Select-Object -Property id, Name

#Update this variable with the correct App ID from the list above
$myappID = 8758

#Collects details on the selected application
$myapp = Get-BarracudaWaaS-Application -authkey $waas_token.key -appid $myappID


#Iterates through each endpoint configured uner the app
Foreach($ep in $myapp.waas_services.id){
    #Get's the specific endpoint details (slight format differnce between querying and endpoint and the app)
    $endpoint = Get-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep

    
    #takes the domainlistimport csv array and adds each one to the endpoint.hostname field. 
    foreach($d in $domainlistimport){
        
          $endpoint.hostnames += $d.Domains
    }

    #Updates the endpoint, with the modified $endpoints variable. 
        if($endpoint.ServiceType -eq "HTTPS"){
           $endpoint | Set-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep -HTTPS 
        }else{
           $endpoint | Set-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep -Debug
        }
    
    Write-Output "Updated Endpoints FQDN's for $($ep)"    

}

Write-Output "Script complete $($domainlistimport.Count) domains added to the endpoints of $($myapp.Name)"
