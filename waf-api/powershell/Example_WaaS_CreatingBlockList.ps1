#or import a CSV in the format below, set the allow column to true of false to permit or deny access
<#
allow,ip,netmask
true,10.2.5.0,255.255.255.0
false,192.168.1.1,255.255.255.128
true,10.7.1.5,255.255.255.255
#>
$list = Get-Content -Path C:\Temp\blocklist.csv | ConvertFrom-Csv -Delimiter "," 

#Provide login creds
$waas_creds = Get-Credential

#Login to WaaS
$waas_token = Login-BarracudaWaaS -credentials $waas_creds 

#Get your Apps
$apps = Get-BarracudaWaaS-Application -authkey $waas_token.key 

$apps | Format-Table

#You need to collect the Application ID from here to use in the next commands.

$appid = <fill this in from the ID in the table>

#Get the existing IP Reputation Settings
$iprep = Get-BarracudaWaaS-IPReputation -authkey $waas_token.key -application_id $appid

#Keeps the existing settings and adds the blocked countries. 
$iprep | Set-BarracudaWaaS-IPReputation -authkey $waas_token.key -id $iprep.id -application_id $appid -network_exceptions $list

#The WaaS API will ignore any duplicate IP's in your input
$postchange = Get-BarracudaWaaS-IPReputation -authkey $waas_token.key -application_id $appid

