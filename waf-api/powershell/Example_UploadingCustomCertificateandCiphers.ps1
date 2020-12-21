
Import-Module BarracudaWaaS -Force

#Provide login credentials for WAF as a Service
$waas_creds = Get-Credential

#Login to WaaS / you may be prompted for MFA at this point. 
$waas_token = Login-BarracudaWaaS -credentials $waas_creds

#Print Available Apps
Get-BarracudaWaaS-Application -authkey $waas_token.key | Select-Object -Property id, Name

#Update this variable with the correct App ID from the list above
$myappID = 8758

$myapp = Get-BarracudaWaaS-Application -authkey $waas_token.key -appid $myappID  | Where-Object -Property waas_services.protocol -eq -Value "HTTPS"

#Collects the endpoint information of the selected Application
$endpoint = Get-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep | Where-Object -Property ServiceType -eq -Value "HTTPS"




$cert = Get-Content -Path "C:\Users\gallen\OneDrive - Barracuda Networks, Inc\Desktop\cer1.pem" -Raw
$key = Get-Content -Path "C:\Users\gallen\OneDrive - Barracuda Networks, Inc\Desktop\key1.pem" -Raw